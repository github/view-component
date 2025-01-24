# frozen_string_literal: true

require "concurrent-ruby"

module ViewComponent
  class Compiler
    # Compiler development mode. Can be either:
    # * true (a blocking mode which ensures thread safety when redefining the `call` method for components,
    #                default in Rails development and test mode)
    # * false(a non-blocking mode, default in Rails production mode)
    class_attribute :development_mode, default: false

    def initialize(component)
      @component = component
      @lock = Mutex.new
    end

    def compiled?
      CompileCache.compiled?(@component)
    end

    def compile(raise_errors: false, force: false)
      return if compiled? && !force
      return if @component == ViewComponent::Base

      @lock.synchronize do
        # this check is duplicated so that concurrent compile calls can still
        # early exit
        return if compiled? && !force

        gather_templates

        if self.class.development_mode && @templates.any?(&:requires_compiled_superclass?)
          @component.superclass.compile(raise_errors: raise_errors)
        end

        if template_errors.present?
          raise TemplateError.new(template_errors) if raise_errors

          # this return is load bearing, and prevents the component from being considered "compiled?"
          return false
        end

        if raise_errors
          @component.validate_initialization_parameters!
          @component.validate_collection_parameter!
        end

        define_render_template_for

        @component.register_default_slots
        @component.build_i18n_backend

        CompileCache.register(@component)
      end
    end

    # @return all matching compiled templates, in priority order based on the requested details from LookupContext
    #
    # @param [ActionView::TemplateDetails::Requested] requested_details i.e. locales, formats, variants
    def find_templates_for(requested_details)
      filtered_templates = @templates.select do |template|
        template.details.matches?(requested_details)
      end

      if filtered_templates.count > 1
        filtered_templates.sort_by! do |template|
          template.details.sort_key_for(requested_details)
        end
      end

      filtered_templates
    end

    private

    attr_reader :templates

    def define_render_template_for
      @templates.each do |template|
        template.compile_to_component
      end

      @component.silence_redefinition_of_method(:render_template_for)

      if @templates.one?
        template = @templates.first
        safe_call = template.safe_method_name_call
        @component.define_method(:render_template_for) do |_|
          @current_template = template
          instance_exec(&safe_call)
        end
      else
        compiler = self
        @component.define_method(:render_template_for) do |details|
          if (@current_template = compiler.find_templates_for(details).first)
            instance_exec(&@current_template.safe_method_name_call)
          else
            raise MissingTemplateError.new(self.class.name, details)
          end
        end
      end
    end

    def template_errors
      @_template_errors ||= begin
        errors = []

        errors << "Couldn't find a template file or inline render method for #{@component}." if @templates.empty?

        # We currently allow components to have both an inline call method and a template for a variant, with the
        # inline call method overriding the template. We should aim to change this in v4 to instead
        # raise an error.
        @templates.reject(&:inline_call?)
          .map { |template| [template.variant, template.format] }
          .tally
          .select { |_, count| count > 1 }
          .each do |tally|
          variant, this_format = tally.first

          variant_string = " for variant `#{variant}`" if variant.present?

          errors << "More than one #{this_format.upcase} template found#{variant_string} for #{@component}. "
        end

        default_template_types = @templates.each_with_object(Set.new) do |template, memo|
          next if template.variant

          memo << :template_file if !template.inline_call?
          memo << :inline_render if template.inline_call? && template.defined_on_self?

          memo
        end

        if default_template_types.length > 1
          errors <<
            "Template file and inline render method found for #{@component}. " \
            "There can only be a template file or inline render method per component."
        end

        # If a template has inline calls, they can conflict with template files the component may use
        # to render. This attempts to catch and raise that issue before run time. For example,
        # `def render_mobile` would conflict with a sidecar template of `component.html+mobile.erb`
        duplicate_template_file_and_inline_call_variants =
          @templates.reject(&:inline_call?).map(&:variant) &
          @templates.select { _1.inline_call? && _1.defined_on_self? }.map(&:variant)

        unless duplicate_template_file_and_inline_call_variants.empty?
          count = duplicate_template_file_and_inline_call_variants.count

          errors <<
            "Template #{"file".pluralize(count)} and inline render #{"method".pluralize(count)} " \
            "found for #{"variant".pluralize(count)} " \
            "#{duplicate_template_file_and_inline_call_variants.map { |v| "'#{v}'" }.to_sentence} " \
            "in #{@component}. There can only be a template file or inline render method per variant."
        end

        @templates.select(&:variant).each_with_object(Hash.new { |h, k| h[k] = Set.new }) do |template, memo|
          memo[template.normalized_variant_name] << template.variant
          memo
        end.each do |_, variant_names|
          next unless variant_names.length > 1

          errors << "Colliding templates #{variant_names.sort.map { |v| "'#{v}'" }.to_sentence} found in #{@component}."
        end

        errors
      end
    end

    def gather_templates
      @templates ||=
        if @component.inline_template.present?
          [Template::Inline.new(
            component: @component,
            inline_template: @component.inline_template
          )]
        else
          path_parser = ActionView::Resolver::PathParser.new
          templates = @component.sidecar_files(
            ActionView::Template.template_handler_extensions
          ).map do |path|
            details = path_parser.parse(path).details
            Template::File.new(component: @component, path: path, details: details)
          end

          component_instance_methods_on_self = @component.instance_methods(false)

          (
            @component.ancestors.take_while { |ancestor| ancestor != ViewComponent::Base } - @component.included_modules
          ).flat_map { |ancestor| ancestor.instance_methods(false).grep(/^call(_|$)/) }
            .uniq
            .each do |method_name|
            templates << Template::InlineCall.new(
              component: @component,
              method_name: method_name,
              defined_on_self: component_instance_methods_on_self.include?(method_name)
            )
          end

          templates
        end
    end
  end
end
