# frozen_string_literal: true

require "action_view/renderer/collection_renderer" if Rails.version.to_f >= 6.1

module ViewComponent
  class Collection
    attr_reader :component
    delegate :format, to: :component

    def render_in(view_context, &block)
      iterator = ActionView::PartialIteration.new(@collection.size)

      component.compile(raise_errors: true)
      component.validate_collection_parameter!(validate_default: true)

      @collection.map do |item|
        content = component.new(**component_options(item, iterator)).render_in(view_context, &block)
        iterator.iterate!
        content
      end.join.html_safe
    end

    private

    def initialize(component, object, **options)
      @component = component
      @collection = collection_variable(object || [])
      @options = options
    end

    def collection_variable(object)
      if object.respond_to?(:to_ary)
        object.to_ary
      else
        raise ArgumentError.new("The value of the argument isn't a valid collection. Make sure it responds to to_ary: #{object.inspect}")
      end
    end

    def component_options(item, iterator)
      item_options = { component.collection_parameter => item }
      item_options[component.collection_counter_parameter] = iterator.index + 1 if component.counter_argument_present?

      @options.merge(item_options)
    end
  end
end
