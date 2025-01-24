# frozen_string_literal: true

module ViewComponent
  class Template
    DataWithSource = Struct.new(:format, :identifier, :short_identifier, :type, keyword_init: true)
    DataNoSource = Struct.new(:source, :identifier, :type, keyword_init: true)

    attr_reader :details

    delegate :virtual_path, to: :@component
    delegate :format, :variant, to: :@details

    def initialize(component:, details:, lineno: nil, path: nil)
      @component = component
      @details = details
      @lineno = lineno
      @path = path
    end

    class File < Template
      def initialize(component:, details:, path:)
        super(
          component: component,
          details: details,
          path: path,
          lineno: 0
        )
      end

      def type
        :file
      end

      # Load file each time we look up #source in case the file has been modified
      def source
        ::File.read(@path)
      end
    end

    class Inline < Template
      attr_reader :source

      def initialize(component:, inline_template:)
        details = ActionView::TemplateDetails.new(nil, inline_template.language.to_sym, nil, nil)

        super(
          component: component,
          details: details,
          path: inline_template.path,
          lineno: inline_template.lineno,
        )

        @source = inline_template.source.dup
      end

      def type
        :inline
      end
    end

    class InlineCall < Template
      def initialize(component:, method_name:, defined_on_self:)
        variant = method_name.to_s.include?("call_") ? method_name.to_s.sub("call_", "").to_sym : nil
        details = ActionView::TemplateDetails.new(nil, nil, nil, variant)

        super(component: component, details: details)

        @call_method_name = method_name
        @defined_on_self = defined_on_self
      end

      def type
        :inline_call
      end

      def compile_to_component
        @component.define_method(safe_method_name, @component.instance_method(@call_method_name))
      end

      def safe_method_name_call
        m = safe_method_name
        proc do
          maybe_escape_html(send(m)) do
            Kernel.warn("WARNING: The #{self.class} component rendered HTML-unsafe output. " \
                          "The output will be automatically escaped, but you may want to investigate.")
          end
        end
      end

      def defined_on_self?
        @defined_on_self
      end
    end

    def compile_to_component
      @component.silence_redefinition_of_method(call_method_name)

      # rubocop:disable Style/EvalWithLocation
      @component.class_eval <<~RUBY, @path, @lineno
        def #{call_method_name}
          #{compiled_source}
        end
      RUBY
      # rubocop:enable Style/EvalWithLocation

      @component.define_method(safe_method_name, @component.instance_method(@call_method_name))
    end

    def safe_method_name_call
      m = safe_method_name
      proc { send(m) }
    end

    def requires_compiled_superclass?
      inline_call? && !defined_on_self?
    end

    def inline_call?
      type == :inline_call
    end

    def default_format?
      format.nil? || format == ViewComponent::Base::VC_INTERNAL_DEFAULT_FORMAT
    end
    alias_method :html?, :default_format?

    def call_method_name
      @call_method_name ||=
        ["call", (normalized_variant_name if variant.present?), (format unless default_format?)]
          .compact.join("_").to_sym
    end

    def safe_method_name
      "_#{call_method_name}_#{@component.name.underscore.gsub("/", "__")}"
    end

    def normalized_variant_name
      variant.to_s.gsub("-", "__")
    end

    private

    def compiled_source
      handler = details.handler_class
      this_source = source
      this_source.rstrip! if @component.strip_trailing_whitespace?

      short_identifier = defined?(Rails.root) ? @path.sub("#{Rails.root}/", "") : @path
      format = self.format || ViewComponent::Base::VC_INTERNAL_DEFAULT_FORMAT
      type = ActionView::Template::Types[format]

      if handler.method(:call).parameters.length > 1
        handler.call(
          DataWithSource.new(format: format, identifier: @path, short_identifier: short_identifier, type: type),
          this_source
        )
      # :nocov:
      # TODO: Remove in v4
      else
        handler.call(DataNoSource.new(source: this_source, identifier: @path, type: type))
      end
      # :nocov:
    end
  end
end
