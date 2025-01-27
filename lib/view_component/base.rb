# frozen_string_literal: true

require "action_view"
require "view_component/collection"
require "view_component/compile_cache"
require "view_component/compiler"
require "view_component/config"
require "view_component/errors"
require "view_component/inline_template"
require "view_component/preview"
require "view_component/slotable"
require "view_component/slotable_default"
require "view_component/template"
require "view_component/translatable"
require "view_component/with_content_helper"
require "view_component/use_helpers"

module ViewComponent
  class Base < ActionView::Base
    class << self
      delegate(*ViewComponent::Config.defaults.keys, to: :config)

      # Returns the current config.
      #
      # @return [ActiveSupport::OrderedOptions]
      def config
        GlobalConfig
      end
    end

    include ViewComponent::InlineTemplate
    include ViewComponent::UseHelpers
    include ViewComponent::Slotable
    include ViewComponent::Translatable
    include ViewComponent::WithContentHelper

    RESERVED_PARAMETER = :content
    VC_INTERNAL_DEFAULT_FORMAT = :html

    # For CSRF authenticity tokens in forms
    delegate :form_authenticity_token, :protect_against_forgery?, :config, to: :helpers

    # For Content Security Policy nonces
    delegate :content_security_policy_nonce, to: :helpers

    # Config option that strips trailing whitespace in templates before compiling them.
    class_attribute :__vc_strip_trailing_whitespace, instance_accessor: false, instance_predicate: false
    self.__vc_strip_trailing_whitespace = false # class_attribute:default doesn't work until Rails 5.2

    delegate :component_config, to: :class

    attr_accessor :__vc_original_view_context

    # Components render in their own view context. Helpers and other functionality
    # require a reference to the original Rails view context, an instance of
    # `ActionView::Base`. Use this method to set a reference to the original
    # view context. Objects that implement this method will render in the component's
    # view context, while objects that don't will render in the original view context
    # so helpers, etc work as expected.
    #
    # @param view_context [ActionView::Base] The original view context.
    # @return [void]
    def set_original_view_context(view_context)
      self.__vc_original_view_context = view_context
    end

    # Entrypoint for rendering components.
    #
    # - `view_context`: ActionView context from calling view
    # - `block`: optional block to be captured within the view context
    #
    # Returns HTML that has been escaped by the respective template handler.
    #
    # @return [String]
    def render_in(view_context, &block)
      self.class.compile(raise_errors: true)

      @view_context = view_context
      self.__vc_original_view_context ||= view_context

      @output_buffer = ActionView::OutputBuffer.new

      @lookup_context ||= view_context.lookup_context

      # required for path helpers in older Rails versions
      @view_renderer ||= view_context.view_renderer

      # For content_for
      @view_flow ||= view_context.view_flow

      # For i18n
      @virtual_path ||= virtual_path

      # For template variants (+phone, +desktop, etc.)
      @__vc_variant ||= @lookup_context.variants.first

      # For caching, such as #cache_if
      @current_template = nil unless defined?(@current_template)
      old_current_template = @current_template
      @current_template = self

      if block && defined?(@__vc_content_set_by_with_content)
        raise DuplicateContentError.new(self.class.name)
      end

      @__vc_content_evaluated = false
      @__vc_render_in_block = block

      before_render

      if render?
        rendered_template = render_template_for(@__vc_variant, __vc_request&.format&.to_sym).to_s

        # Avoid allocating new string when output_preamble and output_postamble are blank
        if output_preamble.blank? && output_postamble.blank?
          rendered_template
        else
          safe_output_preamble + rendered_template + safe_output_postamble
        end
      else
        ""
      end
    ensure
      @current_template = old_current_template
    end

    # Subclass components that call `super` inside their template code will cause a
    # double render if they emit the result.
    #
    # ```erb
    # <%= super %> # double-renders
    # <% super %> # doesn't double-render
    # ```
    #
    # `super` also doesn't consider the current variant. `render_parent` renders the
    # parent template considering the current variant and emits the result without
    # double-rendering.
    def render_parent
      render_parent_to_string
      nil
    end

    # Renders the parent component to a string and returns it. This method is meant
    # to be used inside custom #call methods when a string result is desired, eg.
    #
    # ```ruby
    # def call
    #   "<div>#{render_parent_to_string}</div>"
    # end
    # ```
    #
    # When rendering the parent inside an .erb template, use `#render_parent` instead.
    def render_parent_to_string
      @__vc_parent_render_level ||= 0 # ensure a good starting value

      begin
        target_render = self.class.instance_variable_get(:@__vc_ancestor_calls)[@__vc_parent_render_level]
        @__vc_parent_render_level += 1

        target_render.bind_call(self, @__vc_variant)
      ensure
        @__vc_parent_render_level -= 1
      end
    end

    # Optional content to be returned before the rendered template.
    #
    # @return [String]
    def output_preamble
      @@default_output_preamble ||= "".html_safe
    end

    # Optional content to be returned after the rendered template.
    #
    # @return [String]
    def output_postamble
      @@default_output_postamble ||= "".html_safe
    end

    # Called before rendering the component. Override to perform operations that
    # depend on having access to the view context, such as helpers.
    #
    # @return [void]
    def before_render
      # noop
    end

    # Override to determine whether the ViewComponent should render.
    #
    # @return [Boolean]
    def render?
      true
    end

    # @private
    def initialize(*)
    end

    # Re-use original view_context if we're not rendering a component.
    #
    # This prevents an exception when rendering a partial inside of a component that has also been rendered outside
    # of the component. This is due to the partials compiled template method existing in the parent `view_context`,
    #  and not the component's `view_context`.
    #
    # @private
    def render(options = {}, args = {}, &block)
      if options.respond_to?(:set_original_view_context)
        options.set_original_view_context(self.__vc_original_view_context)
        super
      else
        __vc_original_view_context.render(options, args, &block)
      end
    end

    # The current controller. Use sparingly as doing so introduces coupling
    # that inhibits encapsulation & reuse, often making testing difficult.
    #
    # @return [ActionController::Base]
    def controller
      raise ControllerCalledBeforeRenderError if view_context.nil?

      @__vc_controller ||= view_context.controller
    end

    # A proxy through which to access helpers. Use sparingly as doing so introduces
    # coupling that inhibits encapsulation & reuse, often making testing difficult.
    #
    # @return [ActionView::Base]
    def helpers
      raise HelpersCalledBeforeRenderError if view_context.nil?
      # Attempt to re-use the original view_context passed to the first
      # component rendered in the rendering pipeline. This prevents the
      # instantiation of a new view_context via `controller.view_context` which
      # always returns a new instance of the view context class.
      #
      # This allows ivars to remain persisted when using the same helper via
      # `helpers` across multiple components and partials.
      @__vc_helpers ||= __vc_original_view_context || controller.view_context
    end

    if ::Rails.env.development? || ::Rails.env.test?
      # @private
      def method_missing(method_name, *args) # rubocop:disable Style/MissingRespondToMissing
        super
      rescue => e # rubocop:disable Style/RescueStandardError
        e.set_backtrace e.backtrace.tap(&:shift)
        raise e, <<~MESSAGE.chomp if view_context && e.is_a?(NameError) && helpers.respond_to?(method_name)
          #{e.message}

          You may be trying to call a method provided as a view helper. Did you mean `helpers.#{method_name}'?
        MESSAGE

        raise
      end
    end

    # Exposes .virtual_path as an instance method
    #
    # @private
    def virtual_path
      self.class.virtual_path
    end

    # For caching, such as #cache_if
    # @private
    def view_cache_dependencies
      []
    end

    # For caching, such as #cache_if
    #
    # @private
    def format
      @__vc_variant if defined?(@__vc_variant)
    end

    # The current request. Use sparingly as doing so introduces coupling that
    # inhibits encapsulation & reuse, often making testing difficult.
    #
    # @return [ActionDispatch::Request]
    def request
      __vc_request
    end

    # Enables consumers to override request/@request
    #
    # @private
    def __vc_request
      @__vc_request ||= controller.request if controller.respond_to?(:request)
    end

    # The content passed to the component instance as a block.
    #
    # @return [String]
    def content
      @__vc_content_evaluated = true
      return @__vc_content if defined?(@__vc_content)

      @__vc_content =
        if __vc_render_in_block_provided?
          view_context.capture(self, &@__vc_render_in_block)
        elsif __vc_content_set_by_with_content_defined?
          @__vc_content_set_by_with_content
        end
    end

    # Whether `content` has been passed to the component.
    #
    # @return [Boolean]
    def content?
      __vc_render_in_block_provided? || __vc_content_set_by_with_content_defined?
    end

    private

    attr_reader :view_context

    def __vc_render_in_block_provided?
      defined?(@view_context) && @view_context && @__vc_render_in_block
    end

    def __vc_content_set_by_with_content_defined?
      defined?(@__vc_content_set_by_with_content)
    end

    def content_evaluated?
      defined?(@__vc_content_evaluated) && @__vc_content_evaluated
    end

    def maybe_escape_html(text)
      return text if __vc_request && !__vc_request.format.html?
      return text if text.blank?

      if text.html_safe?
        text
      else
        yield
        html_escape(text)
      end
    end

    def safe_output_preamble
      maybe_escape_html(output_preamble) do
        Kernel.warn("WARNING: The #{self.class} component was provided an HTML-unsafe preamble. The preamble will be automatically escaped, but you may want to investigate.")
      end
    end

    def safe_output_postamble
      maybe_escape_html(output_postamble) do
        Kernel.warn("WARNING: The #{self.class} component was provided an HTML-unsafe postamble. The postamble will be automatically escaped, but you may want to investigate.")
      end
    end

    # Set the controller used for testing components:
    #
    # ```ruby
    # config.view_component.test_controller = "MyTestController"
    # ```
    #
    # Defaults to `nil`. If this is falsy, `"ApplicationController"` is used. Can also be
    # configured on a per-test basis using `with_controller_class`.
    #

    # Set if render monkey patches should be included or not in Rails <6.1:
    #
    # ```ruby
    # config.view_component.render_monkey_patch_enabled = false
    # ```
    #

    # Path for component files
    #
    # ```ruby
    # config.view_component.view_component_path = "app/my_components"
    # ```
    #
    # Defaults to `nil`. If this is falsy, `app/components` is used.
    #

    # Parent class for generated components
    #
    # ```ruby
    # config.view_component.component_parent_class = "MyBaseComponent"
    # ```
    #
    # Defaults to nil. If this is falsy, generators will use
    # "ApplicationComponent" if defined, "ViewComponent::Base" otherwise.
    #

    # Configuration for generators.
    #
    # All options under this namespace default to `false` unless otherwise
    # stated.
    #
    # #### #sidecar
    #
    # Always generate a component with a sidecar directory:
    #
    # ```ruby
    # config.view_component.generate.sidecar = true
    # ```
    #
    # #### #stimulus_controller
    #
    # Always generate a Stimulus controller alongside the component:
    #
    # ```ruby
    # config.view_component.generate.stimulus_controller = true
    # ```
    #
    # #### `#typescript`
    #
    # Generate TypeScript files instead of JavaScript files:
    #
    # ```ruby
    # config.view_component.generate.typescript = true
    # ```
    #
    # #### #locale
    #
    # Always generate translations file alongside the component:
    #
    # ```ruby
    # config.view_component.generate.locale = true
    # ```
    #
    # #### #distinct_locale_files
    #
    # Always generate as many translations files as available locales:
    #
    # ```ruby
    # config.view_component.generate.distinct_locale_files = true
    # ```
    #
    # One file will be generated for each configured `I18n.available_locales`,
    # falling back to `[:en]` when no `available_locales` is defined.
    #
    # #### #preview
    #
    # Always generate preview alongside the component:
    #
    # ```ruby
    # config.view_component.generate.preview = true
    # ```
    #
    #  Defaults to `false`.

    class << self
      # The file path of the component Ruby file.
      #
      # @return [String]
      attr_reader :identifier

      # @private
      attr_writer :identifier

      # @private
      attr_accessor :virtual_path

      # Find sidecar files for the given extensions.
      #
      # The provided array of extensions is expected to contain
      # strings starting without the dot, example: `["erb", "haml"]`.
      #
      # For example, one might collect sidecar CSS files that need to be compiled.
      # @param extensions [Array<String>] Extensions of which to return matching sidecar files.
      def sidecar_files(extensions)
        return [] unless identifier

        extensions = extensions.join(",")

        # view files in a directory named like the component
        directory = File.dirname(identifier)
        filename = File.basename(identifier, ".rb")
        component_name = name.demodulize.underscore

        # Add support for nested components defined in the same file.
        #
        # for example
        #
        # class MyComponent < ViewComponent::Base
        #   class MyOtherComponent < ViewComponent::Base
        #   end
        # end
        #
        # Without this, `MyOtherComponent` will not look for `my_component/my_other_component.html.erb`
        nested_component_files =
          if name.include?("::") && component_name != filename
            Dir["#{directory}/#{filename}/#{component_name}.*{#{extensions}}"]
          else
            []
          end

        # view files in the same directory as the component
        sidecar_files = Dir["#{directory}/#{component_name}.*{#{extensions}}"]

        sidecar_directory_files = Dir["#{directory}/#{component_name}/#{filename}.*{#{extensions}}"]

        (sidecar_files - [identifier] + sidecar_directory_files + nested_component_files).uniq
      end

      # Render a component for each element in a collection ([documentation](/guide/collections)):
      #
      # ```ruby
      # render(ProductsComponent.with_collection(@products, foo: :bar))
      # ```
      #
      # @param collection [Enumerable] A list of items to pass the ViewComponent one at a time.
      # @param spacer_component [ViewComponent::Base] Component instance to be rendered between items.
      # @param args [Arguments] Arguments to pass to the ViewComponent every time.
      def with_collection(collection, spacer_component: nil, **args)
        Collection.new(self, collection, spacer_component, **args)
      end

      # @private
      def inherited(child)
        # Compile so child will inherit compiled `call_*` template methods that
        # `compile` defines
        compile

        # Give the child its own personal #render_template_for to protect against the case when
        # eager loading is disabled and the parent component is rendered before the child. In
        # such a scenario, the parent will override ViewComponent::Base#render_template_for,
        # meaning it will not be called for any children and thus not compile their templates.
        if !child.instance_methods(false).include?(:render_template_for) && !child.compiled?
          child.class_eval <<~RUBY, __FILE__, __LINE__ + 1
            def render_template_for(variant = nil, format = nil)
              # Force compilation here so the compiler always redefines render_template_for.
              # This is mostly a safeguard to prevent infinite recursion.
              self.class.compile(raise_errors: true, force: true)
              # .compile replaces this method; call the new one
              render_template_for(variant, format)
            end
          RUBY
        end

        # If Rails application is loaded, add application url_helpers to the component context
        # we need to check this to use this gem as a dependency
        if defined?(Rails) && Rails.application && !(child < Rails.application.routes.url_helpers)
          child.include Rails.application.routes.url_helpers
        end

        # Derive the source location of the component Ruby file from the call stack.
        # We need to ignore `inherited` frames here as they indicate that `inherited`
        # has been re-defined by the consuming application, likely in ApplicationComponent.
        # We use `base_label` method here instead of `label` to avoid cases where the method
        # owner is included in a prefix like `ApplicationComponent.inherited`.
        child.identifier = caller_locations(1, 10).reject { |l| l.base_label == "inherited" }[0].path

        # If Rails application is loaded, removes the first part of the path and the extension.
        if defined?(Rails) && Rails.application
          child.virtual_path = child.identifier.gsub(
            /(.*#{Regexp.quote(GlobalConfig.view_component_path)})|(\.rb)/, ""
          )
        end

        # Set collection parameter to the extended component
        child.with_collection_parameter provided_collection_parameter

        if instance_methods(false).include?(:render_template_for)
          vc_ancestor_calls = defined?(@__vc_ancestor_calls) ? @__vc_ancestor_calls.dup : []

          vc_ancestor_calls.unshift(instance_method(:render_template_for))
          child.instance_variable_set(:@__vc_ancestor_calls, vc_ancestor_calls)
        end

        super
      end

      # @private
      def compiled?
        compiler.compiled?
      end

      # @private
      def ensure_compiled
        compile unless compiled?
      end

      # @private
      def compile(raise_errors: false, force: false)
        compiler.compile(raise_errors: raise_errors, force: force)
      end

      # @private
      def compiler
        @__vc_compiler ||= Compiler.new(self)
      end

      # Set the parameter name used when rendering elements of a collection ([documentation](/guide/collections)):
      #
      # ```ruby
      # with_collection_parameter :item
      # ```
      #
      # @param parameter [Symbol] The parameter name used when rendering elements of a collection.
      def with_collection_parameter(parameter)
        @provided_collection_parameter = parameter
        @initialize_parameters = nil
      end

      # Strips trailing whitespace from templates before compiling them.
      #
      # ```ruby
      # class MyComponent < ViewComponent::Base
      #   strip_trailing_whitespace
      # end
      # ```
      #
      # @param value [Boolean] Whether to strip newlines.
      def strip_trailing_whitespace(value = true)
        self.__vc_strip_trailing_whitespace = value
      end

      # Whether trailing whitespace will be stripped before compilation.
      #
      # @return [Boolean]
      def strip_trailing_whitespace?
        __vc_strip_trailing_whitespace
      end

      # Ensure the component initializer accepts the
      # collection parameter. By default, we don't
      # validate that the default parameter name
      # is accepted, as support for collection
      # rendering is optional.
      # @private
      def validate_collection_parameter!(validate_default: false)
        parameter = validate_default ? collection_parameter : provided_collection_parameter

        return unless parameter
        return if initialize_parameter_names.include?(parameter) || splatted_keyword_argument_present?

        # If Ruby can't parse the component class, then the initialize
        # parameters will be empty and ViewComponent will not be able to render
        # the component.
        if initialize_parameters.empty?
          raise EmptyOrInvalidInitializerError.new(name, parameter)
        end

        raise MissingCollectionArgumentError.new(name, parameter)
      end

      # Ensure the component initializer doesn't define
      # invalid parameters that could override the framework's
      # methods.
      # @private
      def validate_initialization_parameters!
        return unless initialize_parameter_names.include?(RESERVED_PARAMETER)

        raise ReservedParameterError.new(name, RESERVED_PARAMETER)
      end

      # @private
      def collection_parameter
        provided_collection_parameter || name && name.demodulize.underscore.chomp("_component").to_sym
      end

      # @private
      def collection_counter_parameter
        :"#{collection_parameter}_counter"
      end

      # @private
      def counter_argument_present?
        initialize_parameter_names.include?(collection_counter_parameter)
      end

      # @private
      def collection_iteration_parameter
        :"#{collection_parameter}_iteration"
      end

      # @private
      def iteration_argument_present?
        initialize_parameter_names.include?(collection_iteration_parameter)
      end

      private

      def splatted_keyword_argument_present?
        initialize_parameters.flatten.include?(:keyrest) &&
          !initialize_parameters.include?([:keyrest, :**]) # Un-named splatted keyword args don't count!
      end

      def initialize_parameter_names
        return attribute_names.map(&:to_sym) if respond_to?(:attribute_names)

        return attribute_types.keys.map(&:to_sym) if Rails::VERSION::MAJOR <= 5 && respond_to?(:attribute_types)

        initialize_parameters.map(&:last)
      end

      def initialize_parameters
        @initialize_parameters ||= instance_method(:initialize).parameters
      end

      def provided_collection_parameter
        @provided_collection_parameter ||= nil
      end
    end

    ActiveSupport.run_load_hooks(:view_component, self)
  end
end
