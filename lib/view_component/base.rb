# frozen_string_literal: true

require "action_view"
require "active_support/configurable"
require "view_component/collection"
require "view_component/compile_cache"
require "view_component/previewable"
require "view_component/slotable"
require "view_component/slotable_v2"

module ViewComponent
  class Base < ActionView::Base
    include ActiveSupport::Configurable
    include ViewComponent::Previewable
    # For CSRF authenticity tokens in forms
    delegate :form_authenticity_token, :protect_against_forgery?, :config, to: :helpers

    class_attribute :content_areas
    self.content_areas = [] # class_attribute:default doesn't work until Rails 5.2

    # EXPERIMENTAL: This API is experimental and may be removed at any time.
    # Hook for allowing components to do work as part of the compilation process.
    #
    # For example, one might compile component-specific assets at this point.
    def self._after_compile
      # noop
    end

    # Entrypoint for rendering components.
    #
    # view_context: ActionView context from calling view
    # block: optional block to be captured within the view context
    #
    # returns HTML that has been escaped by the respective template handler
    #
    # Example subclass:
    #
    # app/components/my_component.rb:
    # class MyComponent < ViewComponent::Base
    #   def initialize(title:)
    #     @title = title
    #   end
    # end
    #
    # app/components/my_component.html.erb
    # <span title="<%= @title %>">Hello, <%= content %>!</span>
    #
    # In use:
    # <%= render MyComponent.new(title: "greeting") do %>world<% end %>
    # returns:
    # <span title="greeting">Hello, world!</span>
    #
    def render_in(view_context, &block)
      self.class.ensure_compiled(raise_errors: true)

      @view_context = view_context
      @lookup_context ||= view_context.lookup_context

      # required for path helpers in older Rails versions
      @view_renderer ||= view_context.view_renderer

      # For content_for
      @view_flow ||= view_context.view_flow

      # For i18n
      @virtual_path ||= virtual_path

      # For template variants (+phone, +desktop, etc.)
      @variant ||= @lookup_context.variants.first

      # For caching, such as #cache_if
      @current_template = nil unless defined?(@current_template)
      old_current_template = @current_template
      @current_template = self

      @_content_evaluated = false
      @_render_in_block = block

      before_render

      if render?
      else
        ""
      end
    ensure
      @current_template = old_current_template
    end

    def before_render
      before_render_check
    end

    def before_render_check
      # noop
    end

    # Hook used for experimental implementation of CSS encapsulation.
    # May be removed or modified at any time, without warning.
    def _after_render
      ""
    end

    def render?
      true
    end

    def initialize(*); end

    # Re-use original view_context if we're not rendering a component.
    #
    # This prevents an exception when rendering a partial inside of a component that has also been rendered outside
    # of the component. This is due to the partials compiled template method existing in the parent `view_context`,
    #  and not the component's `view_context`.
    def render(options = {}, args = {}, &block)
      if options.is_a? ViewComponent::Base
        super
      else
        view_context.render(options, args, &block)
      end
    end

    def controller
      raise ViewContextCalledBeforeRenderError, "`controller` can only be called at render time." if view_context.nil?
      @controller ||= view_context.controller
    end

    # Provides a proxy to access helper methods from the context of the current controller
    def helpers
      raise ViewContextCalledBeforeRenderError, "`helpers` can only be called at render time." if view_context.nil?
      @helpers ||= controller.view_context
    end

    # Exposes .virtual_path as an instance method
    def virtual_path
      self.class.virtual_path
    end

    # For caching, such as #cache_if
    def view_cache_dependencies
      []
    end

    # For caching, such as #cache_if
    def format
      # Ruby 2.6 throws a warning without checking `defined?`, 2.7 does not
      if defined?(@variant)
        @variant
      end
    end

    # Assign the provided content to the content area accessor
    def with(area, content = nil, &block)
      unless content_areas.include?(area)
        raise ArgumentError.new "Unknown content_area '#{area}' - expected one of '#{content_areas}'"
      end

      if block_given?
        content = view_context.capture(&block)
      end

      instance_variable_set("@#{area}".to_sym, content)
      nil
    end

    def with_variant(variant)
      @variant = variant

      self
    end

    private

    # Exposes the current request to the component.
    # Use sparingly as doing so introduces coupling
    # that inhibits encapsulation & reuse.
    def request
      @request ||= controller.request
    end

    attr_reader :view_context
    def content
      return @_content if defined?(@_content)
      @_content_evaluated = true

      @_content = if @view_context && @_render_in_block
        view_context.capture(self, &@_render_in_block)
      end
    end

    def content_evaluated?
      @_content_evaluated
    end

    # The controller used for testing components.
    # Defaults to ApplicationController, but can be configured
    # on a per-test basis using `with_controller_class`.
    # This should be set early in the initialization process and should be a string.
    mattr_accessor :test_controller
    @@test_controller = "ApplicationController"

    # Configure if render monkey patches should be included or not in Rails <6.1.
    mattr_accessor :render_monkey_patch_enabled, instance_writer: false, default: true

    class << self
      attr_accessor :source_location, :virtual_path
      end

      # Render a component collection.
      def with_collection(collection, **args)
        Collection.new(self, collection, **args)
      end

      # Provide identifier for ActionView template annotations
      def short_identifier
        @short_identifier ||= defined?(Rails.root) ? source_location.sub("#{Rails.root}/", "") : source_location
      end

      def inherited(child)
        # Compile so child will inherit compiled `call_*` template methods that
        # `compile` defines
        ensure_compiled

        # If Rails application is loaded, add application url_helpers to the component context
        # we need to check this to use this gem as a dependency
        if defined?(Rails) && Rails.application
          child.include Rails.application.routes.url_helpers unless child < Rails.application.routes.url_helpers
        end

        # Derive the source location of the component Ruby file from the call stack.
        # We need to ignore `inherited` frames here as they indicate that `inherited`
        # has been re-defined by the consuming application, likely in ApplicationComponent.
        child.source_location = caller_locations(1, 10).reject { |l| l.label == "inherited" }[0].absolute_path

        # Removes the first part of the path and the extension.
        child.virtual_path = child.source_location.gsub(%r{(.*app/components)|(\.rb)}, "")

        super
      end

      def compiled?
        template_compiler.compiled?
      end

      # Compile templates to instance methods, assuming they haven't been compiled already.
      #
      # Do as much work as possible in this step, as doing so reduces the amount
      # of work done each time a component is rendered.
      def template_compiler
        @_template_compiler ||= Compiler.new(self)
      end

      # we'll eventually want to update this to support other types
      def type
        "text/html"
      end

      def format
        :html
      end

      def identifier
        source_location
      end

      def with_content_areas(*areas)
        ActiveSupport::Deprecation.warn(
          "`with_content_areas` is deprecated and will be removed in ViewComponent v3.0.0.\n" \
          "Use slots (https://viewcomponent.org/guide/slots.html) instead."
        )

        if areas.include?(:content)
          raise ArgumentError.new ":content is a reserved content area name. Please use another name, such as ':body'"
        end

        areas.each do |area|
          define_method area.to_sym do
            content unless content_evaluated? # ensure content is loaded so content_areas will be defined
            instance_variable_get(:"@#{area}") if instance_variable_defined?(:"@#{area}")
          end
        end

        self.content_areas = areas
      end

      # Support overriding collection parameter name
      def with_collection_parameter(param)
        @provided_collection_parameter = param
      end

      # Ensure the component initializer accepts the
      # collection parameter. By default, we do not
      # validate that the default parameter name
      # is accepted, as support for collection
      # rendering is optional.
      def validate_collection_parameter!(validate_default: false)
        parameter = validate_default ? collection_parameter : provided_collection_parameter

        return unless parameter
        return if initialize_parameter_names.include?(parameter)

        # If Ruby cannot parse the component class, then the initalize
        # parameters will be empty and ViewComponent will not be able to render
        # the component.
        if initialize_parameters.empty?
          raise ArgumentError.new(
            "#{self} initializer is empty or invalid."
          )
        end

        raise ArgumentError.new(
          "#{self} initializer must accept " \
          "`#{parameter}` collection parameter."
        )
      end

      # Ensure the component initializer does not define
      # invalid parameters that could override the framework's
      # methods.
      def validate_initialization_parameters!
        return unless initialize_parameter_names.include?(RESERVED_PARAMETER)

        raise ArgumentError.new(
          "#{self} initializer cannot contain " \
          "`#{RESERVED_PARAMETER}` since it will override a " \
          "public ViewComponent method."
        )
      end

      def collection_parameter
        if provided_collection_parameter
          provided_collection_parameter
        else
          name && name.demodulize.underscore.chomp("_component").to_sym
        end
      end

      def collection_counter_parameter
        "#{collection_parameter}_counter".to_sym
      end

      def counter_argument_present?
        instance_method(:initialize).parameters.map(&:second).include?(collection_counter_parameter)
      end

      def initialize_parameter_names
        initialize_parameters.map(&:last)
      end
      end

      def provided_collection_parameter
        @provided_collection_parameter ||= nil
      end
    end

    ActiveSupport.run_load_hooks(:view_component, self)
  end
end
