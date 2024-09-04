# frozen_string_literal: true

require "concurrent-ruby"

module ViewComponent
  class Compiler
    # Compiler mode. Can be either:
    # * development (a blocking mode which ensures thread safety when redefining the `call` method for components,
    #                default in Rails development and test mode)
    # * production (a non-blocking mode, default in Rails production mode)
    DEVELOPMENT_MODE = :development
    PRODUCTION_MODE = :production

    class_attribute :mode, default: PRODUCTION_MODE

    def initialize(component)
      @component = component
      @redefinition_lock = Mutex.new
      @variants_rendering_templates = Set.new
    end

    def compiled?
      CompileCache.compiled?(component)
    end

    def compile(raise_errors: false, force: false)
      return if (compiled? && !force) || component == ViewComponent::Base

      gather_templates

      if (
        self.class.mode == DEVELOPMENT_MODE &&
        templates.select { _1.type != :inline_call }.empty? &&
        !(component.instance_methods(false).include?(:call) || component.private_instance_methods(false).include?(:call))
      )
        component.superclass.compile(raise_errors: raise_errors)
      end

      if template_errors.present?
        raise TemplateError.new(template_errors) if raise_errors

        return
      end

      if raise_errors
        component.validate_initialization_parameters!
        component.validate_collection_parameter!
      end

      templates.each(&:compile_to_component)

      define_render_template_for

      component.register_default_slots
      component.build_i18n_backend

      CompileCache.register(component)
    end

    def renders_template_for_variant?(variant)
      @variants_rendering_templates.include?(variant)
    end

    private

    attr_reader :component, :redefinition_lock, :templates

    def define_render_template_for
      if template = templates.find { _1.inline? }
        template.define_safe_method

        body = template.safe_method_name
      else
        branches = []

        templates.each do |template|
          template.define_safe_method

          if template.type == :inline_call
            branches << ["variant&.to_sym == :'#{template.variant}'", template.safe_method_name]
          else
            format_conditional =
              if template.html?
                "(format == :html || format.nil?)"
              else
                "format == #{template.format.inspect}"
              end

            variant_conditional =
              if template.variant.nil?
                "variant.nil?"
              else
                "variant&.to_sym == :'#{template.variant}'"
              end

            branches << ["#{variant_conditional} && #{format_conditional}", template.safe_method_name]
          end
        end

        # Just use default method name if no conditional branches or if there is a single
        # conditional branch that just calls the default method_name
        if branches.length == 1
          body = branches[0].last
        else
          body = +""

          branches.each do |conditional, method_body|
            body << "#{(!body.present?) ? "if" : "elsif"} #{conditional}\n  #{method_body}\n"
          end

          body << "else\n  #{templates.find { _1.variant.nil? && _1.html? }.safe_method_name}\nend"
        end
      end

      redefinition_lock.synchronize do
        component.silence_redefinition_of_method(:render_template_for)
        component.class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def render_template_for(variant = nil, format = nil)
          #{body}
        end
        RUBY
      end
    end

    def template_errors
      @__vc_template_errors ||=
        begin
          errors = []

          errors << "Couldn't find a template file or inline render method for #{component}." if templates.empty?

          templates.select { _1.type != :inline_call }.
            map { |template| [template.variant, template.format] }.
            tally.
            select { |_, count| count > 1 }.
            each do |tally|
            variant, this_format = tally[0]

            variant_string = " for variant `#{variant}`" if variant.present?

            errors << "More than one #{this_format.upcase} template found#{variant_string} for #{component}. "
          end

          if templates.find { _1.variant.nil? && _1.type != :inline_call } && inline_calls_defined_on_self.include?(:call)
            errors <<
              "Template file and inline render method found for #{component}. " \
              "There can only be a template file or inline render method per component."
          end

          duplicate_template_file_and_inline_variant_calls =
            templates.select { _1.type != :inline_call }.map(&:variant) & variants_from_inline_calls(inline_calls_defined_on_self)

          unless duplicate_template_file_and_inline_variant_calls.empty?
            count = duplicate_template_file_and_inline_variant_calls.count

            errors <<
              "Template #{"file".pluralize(count)} and inline render #{"method".pluralize(count)} " \
              "found for #{"variant".pluralize(count)} " \
              "#{duplicate_template_file_and_inline_variant_calls.map { |v| "'#{v}'" }.to_sentence} " \
              "in #{component}. " \
              "There can only be a template file or inline render method per variant."
          end

          uniq_variants = variants.compact.uniq
          normalized_variants = uniq_variants.map { |variant| normalized_variant_name(variant) }

          colliding_variants = uniq_variants.select do |variant|
            normalized_variants.count(normalized_variant_name(variant)) > 1
          end

          unless colliding_variants.empty?
            errors <<
              "Colliding templates #{colliding_variants.sort.map { |v| "'#{v}'" }.to_sentence} " \
              "found in #{component}."
          end

          errors
        end
    end

    def gather_templates
      @templates ||=
        begin
          templates = component.sidecar_files(
            ActionView::Template.template_handler_extensions
          ).map do |path|
            pieces = File.basename(path).split(".")

            out = Template.new(
              redefinition_lock: redefinition_lock,
              component: component,
              type: :file,
              path: path,
              lineno: 0,
              source: nil,
              extension: pieces.last,
              this_format: pieces[1..-2].join(".").split("+").first&.to_sym,
              variant: pieces[1..-2].join(".").split("+").second&.to_sym
            )

            @variants_rendering_templates << out.variant

            out
          end

          inline_calls.each do |method_name|
            templates << Template.new(
              redefinition_lock: redefinition_lock,
              component: component,
              type: :inline_call,
              path: nil,
              lineno: nil,
              source: nil,
              extension: nil,
              this_format: :html,
              variant: method_name.to_s.include?("call_") ? method_name.to_s.sub("call_", "").to_sym : nil,
              method_name: method_name
            )
          end

          if component.inline_template.present?
            templates << Template.new(
              redefinition_lock: redefinition_lock,
              component: component,
              type: :inline,
              path: component.inline_template.path,
              lineno: component.inline_template.lineno,
              source: component.inline_template.source.dup,
              extension: component.inline_template.language,
              this_format: nil,
              variant: nil
            )
          end

          templates
        end
    end

    def inline_calls
      @inline_calls ||=
        begin
          # Fetch only ViewComponent ancestor classes to limit the scope of
          # finding inline calls
          view_component_ancestors =
            (
              component.ancestors.take_while { |ancestor| ancestor != ViewComponent::Base } -
              component.included_modules
            )

          view_component_ancestors.flat_map { |ancestor| ancestor.instance_methods(false).grep(/^call(_|$)/) }.uniq
        end
    end

    def inline_calls_defined_on_self
      @inline_calls_defined_on_self ||= component.instance_methods(false).grep(/^call(_|$)/)
    end

    def variants
      @__vc_variants = (
        templates.map { |template| template.variant } + variants_from_inline_calls(inline_calls)
      ).compact.uniq
    end

    def variants_from_inline_calls(calls)
      calls.reject { |call| call == :call }.map do |variant_call|
        variant_call.to_s.sub("call_", "").to_sym
      end
    end

    def normalized_variant_name(variant)
      variant.to_s.gsub("-", "__").gsub(".", "___")
    end

    class Template
      attr_reader :variant, :type, :call_method_name

      def initialize(redefinition_lock:, component:, path:, source:, extension:, this_format:, lineno:, variant:, type:, method_name: nil)
        @redefinition_lock, @component, @path, @source, @extension, @this_format, @lineno, @variant, @type =
          redefinition_lock, component, path, source, extension, this_format, lineno, variant, type
        @source_originally_nil = @source.nil?

        @call_method_name =
          if @method_name
            @method_name
          else
            out = +"call"
            out << "_#{normalized_variant_name}" if @variant.present?
            out << "_#{@this_format}" if @this_format.present? && @this_format != :html
            out
          end
      end

      def compile_to_component
        return if @type == :inline_call

        @redefinition_lock.synchronize do
          @component.silence_redefinition_of_method(call_method_name)

          # rubocop:disable Style/EvalWithLocation
          @component.class_eval <<-RUBY, @path, @lineno
          def #{call_method_name}
            #{compiled_source}
          end
          RUBY
          # rubocop:enable Style/EvalWithLocation
        end
      end

      def inline?
        @type == :inline
      end

      def html?
        @this_format == :html
      end

      def format
        @this_format
      end

      def safe_method_name
        "_#{call_method_name}_#{@component.name.underscore.gsub("/", "__")}"
      end

      def define_safe_method
        @component.define_method(safe_method_name, @component.instance_method(call_method_name))
      end

      private

      def source
        if @source_originally_nil
          # Load file each time we look up #source in case the file has been modified
          File.read(@path)
        else
          @source
        end
      end

      def normalized_variant_name
        @variant.to_s.gsub("-", "__").gsub(".", "___")
      end

      def compiled_source
        handler = ActionView::Template.handler_for_extension(@extension)
        this_source = source
        this_source.rstrip! if @component.strip_trailing_whitespace?

        short_identifier = defined?(Rails.root) ? @path.sub("#{Rails.root}/", "") : @path
        type = ActionView::Template::Types[@this_format]

        if handler.method(:call).parameters.length > 1
          handler.call(
            OpenStruct.new(
              format: @this_format,
              identifier: @path,
              short_identifier: short_identifier,
              type: type
            ),
            this_source
          )
        # :nocov:
        else
          handler.call(
            OpenStruct.new(
              source: this_source,
              identifier: @path,
              type: type
            )
          )
        end
        # :nocov:
      end
    end
  end
end
