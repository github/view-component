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

    def initialize(component_class)
      @component_class = component_class
      @redefinition_lock = Mutex.new
      @variants_rendering_templates = Set.new
    end

    def compiled?
      CompileCache.compiled?(component_class)
    end

    def development?
      self.class.mode == DEVELOPMENT_MODE
    end

    def compile(raise_errors: false, force: false)
      return if compiled? && !force
      return if component_class == ViewComponent::Base

      component_class.superclass.compile(raise_errors: raise_errors) if should_compile_superclass?

      if template_errors.present?
        raise TemplateError.new(template_errors) if raise_errors

        return
      end

      if raise_errors
        component_class.validate_initialization_parameters!
        component_class.validate_collection_parameter!
      end

      if has_inline_template?
        template = component_class.inline_template

        redefinition_lock.synchronize do
          component_class.silence_redefinition_of_method("call")
          # rubocop:disable Style/EvalWithLocation
          component_class.class_eval <<-RUBY, template.path, template.lineno
          def call
            #{compiled_inline_template(template)}
          end
          RUBY
          # rubocop:enable Style/EvalWithLocation

          component_class.define_method(:"_call_#{safe_class_name}", component_class.instance_method(:call))

          component_class.silence_redefinition_of_method("render_template_for")
          component_class.class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def render_template_for(variant = nil, format = nil)
            _call_#{safe_class_name}
          end
          RUBY
        end
      else
        templates.each do |template|
          method_name = call_method_name(template[:variant], template[:format])
          @variants_rendering_templates << template[:variant]

          redefinition_lock.synchronize do
            component_class.silence_redefinition_of_method(method_name)
            # rubocop:disable Style/EvalWithLocation
            component_class.class_eval <<-RUBY, template[:path], 0
            def #{method_name}
              #{compiled_template(template[:path], template[:format])}
            end
            RUBY
            # rubocop:enable Style/EvalWithLocation
          end
        end

        define_render_template_for
      end

      component_class.registered_slots.each do |slot_name, config|
        config[:default_method] = component_class.instance_methods.find { |method_name| method_name == :"default_#{slot_name}" }

        component_class.registered_slots[slot_name] = config
      end

      component_class.build_i18n_backend

      CompileCache.register(component_class)
    end

    def renders_template_for_variant?(variant)
      @variants_rendering_templates.include?(variant)
    end

    private

    attr_reader :component_class, :redefinition_lock

    def define_render_template_for
      branches = []
      default_method_name = "_call_#{safe_class_name}"

      templates.each do |template|
        safe_name = +"_call"
        variant_name = normalized_variant_name(template[:variant])
        safe_name << "_#{variant_name}" if variant_name.present?
        safe_name << "_#{template[:format]}" if template[:format].present? && template[:format] != :html
        safe_name << "_#{safe_class_name}"

        if safe_name == default_method_name
          next
        else
          component_class.define_method(
            safe_name,
            component_class.instance_method(
              call_method_name(template[:variant], template[:format])
            )
          )
        end

        format_conditional =
          if template[:format] == :html
            "(format == :html || format.nil?)"
          else
            "format == #{template[:format].inspect}"
          end

        variant_conditional =
          if template[:variant].nil?
            "variant.nil?"
          else
            "variant&.to_sym == :'#{template[:variant]}'"
          end

        branches << ["#{variant_conditional} && #{format_conditional}", safe_name]
      end

      variants_from_inline_calls(inline_calls).compact.uniq.each do |variant|
        safe_name = "_call_#{normalized_variant_name(variant)}_#{safe_class_name}"
        component_class.define_method(safe_name, component_class.instance_method(call_method_name(variant)))

        branches << ["variant&.to_sym == :'#{variant}'", safe_name]
      end

      component_class.define_method(:"#{default_method_name}", component_class.instance_method(:call))

      # Just use default method name if no conditional branches or if there is a single
      # conditional branch that just calls the default method_name
      if branches.empty? || (branches.length == 1 && branches[0].last == default_method_name)
        body = default_method_name
      else
        body = +""

        branches.each do |conditional, method_body|
          body << "#{(!body.present?) ? "if" : "elsif"} #{conditional}\n  #{method_body}\n"
        end

        body << "else\n  #{default_method_name}\nend"
      end

      redefinition_lock.synchronize do
        component_class.silence_redefinition_of_method(:render_template_for)
        component_class.class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def render_template_for(variant = nil, format = nil)
          #{body}
        end
        RUBY
      end
    end

    def has_inline_template?
      component_class.respond_to?(:inline_template) && component_class.inline_template.present?
    end

    def template_errors
      @__vc_template_errors ||=
        begin
          errors = []

          if (templates + inline_calls).empty? && !has_inline_template?
            errors << "Couldn't find a template file or inline render method for #{component_class}."
          end

          templates.
            map { |template| [template[:variant], template[:format]] }.
            tally.
            select { |_, count| count > 1 }.
            each do |tally|
            variant, this_format = tally[0]

            variant_string = " for variant `#{variant}`" if variant.present?

            errors << "More than one #{this_format.upcase} template found#{variant_string} for #{component_class}. "
          end

          if templates.find { |template| template[:variant].nil? } && inline_calls_defined_on_self.include?(:call)
            errors <<
              "Template file and inline render method found for #{component_class}. " \
              "There can only be a template file or inline render method per component."
          end

          duplicate_template_file_and_inline_variant_calls =
            templates.pluck(:variant) & variants_from_inline_calls(inline_calls_defined_on_self)

          unless duplicate_template_file_and_inline_variant_calls.empty?
            count = duplicate_template_file_and_inline_variant_calls.count

            errors <<
              "Template #{"file".pluralize(count)} and inline render #{"method".pluralize(count)} " \
              "found for #{"variant".pluralize(count)} " \
              "#{duplicate_template_file_and_inline_variant_calls.map { |v| "'#{v}'" }.to_sentence} " \
              "in #{component_class}. " \
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
              "found in #{component_class}."
          end

          errors
        end
    end

    def templates
      @templates ||=
        begin
          extensions = ActionView::Template.template_handler_extensions

          component_class.sidecar_files(extensions).each_with_object([]) do |path, memo|
            pieces = File.basename(path).split(".")
            memo << {
              path: path,
              format: pieces[1..-2].join(".").split("+").first&.to_sym,
              variant: pieces[1..-2].join(".").split("+").second&.to_sym,
              handler: pieces.last
            }
          end
        end
    end

    def inline_calls
      @inline_calls ||=
        begin
          # Fetch only ViewComponent ancestor classes to limit the scope of
          # finding inline calls
          view_component_ancestors =
            (
              component_class.ancestors.take_while { |ancestor| ancestor != ViewComponent::Base } -
              component_class.included_modules
            )

          view_component_ancestors.flat_map { |ancestor| ancestor.instance_methods(false).grep(/^call(_|$)/) }.uniq
        end
    end

    def inline_calls_defined_on_self
      @inline_calls_defined_on_self ||= component_class.instance_methods(false).grep(/^call(_|$)/)
    end

    def formats
      @__vc_variants = (templates.map { |template| template[:format] }).compact.uniq
    end

    def variants
      @__vc_variants = (
        templates.map { |template| template[:variant] } + variants_from_inline_calls(inline_calls)
      ).compact.uniq
    end

    def variants_from_inline_calls(calls)
      calls.reject { |call| call == :call }.map do |variant_call|
        variant_call.to_s.sub("call_", "").to_sym
      end
    end

    def compiled_inline_template(template)
      handler = ActionView::Template.handler_for_extension(template.language)
      template = template.source.dup

      compile_template(template, handler)
    end

    def compiled_template(file_path, format)
      handler = ActionView::Template.handler_for_extension(File.extname(file_path).delete("."))
      template = File.read(file_path)

      compile_template(template, handler, file_path, format)
    end

    def compile_template(template, handler, identifier = component_class.source_location, format = :html)
      template.rstrip! if component_class.strip_trailing_whitespace?

      short_identifier = defined?(Rails.root) ? identifier.sub("#{Rails.root}/", "") : identifier
      type = ActionView::Template::Types[format]

      if handler.method(:call).parameters.length > 1
        handler.call(
          OpenStruct.new(
            format: format,
            identifier: identifier,
            short_identifier: short_identifier,
            type: type
          ),
          template
        )
      # :nocov:
      else
        handler.call(
          OpenStruct.new(
            source: template,
            identifier: identifier,
            type: type
          )
        )
      end
      # :nocov:
    end

    def call_method_name(variant, format = nil)
      out = +"call"
      out << "_#{normalized_variant_name(variant)}" if variant.present?
      out << "_#{format}" if format.present? && format != :html && formats.length > 1
      out
    end

    def normalized_variant_name(variant)
      variant.to_s.gsub("-", "__").gsub(".", "___")
    end

    def safe_class_name
      @safe_class_name ||= component_class.name.underscore.gsub("/", "__")
    end

    def should_compile_superclass?
      development? && templates.empty? && !has_inline_template? && !call_defined?
    end

    def call_defined?
      component_class.instance_methods(false).include?(:call) ||
        component_class.private_instance_methods(false).include?(:call)
    end
  end
end
