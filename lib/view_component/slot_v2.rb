# frozen_string_literal: true

require "view_component/with_content_helper"

module ViewComponent
  class SlotV2
    include ViewComponent::WithContentHelper

    attr_writer :__vc_component_instance, :__vc_content_block, :__vc_content

    def initialize(parent)
      @parent = parent
    end

    # Used to render the slot content in the template
    #
    # There's currently 3 different values that may be set, that we can render.
    #
    # If the slot renderable is a component, the string class name of a
    # component, or a function that returns a component, we render that
    # component instance, returning the string.
    #
    # If the slot renderable is a function and returns a string, it is
    # set as `@__vc_content` and is returned directly.
    #
    # If there is no slot renderable, we evaluate the block passed to
    # the slot and return it.
    def to_s
      return @content if defined?(@content)

      view_context = @parent.send(:view_context)

      if defined?(@__vc_content_block) && defined?(@__vc_content_set_by_with_content)
        raise ArgumentError.new(
          "It looks like a block was provided after calling `with_content` on #{self.class.name}, " \
          "which means that ViewComponent doesn't know which content to use.\n\n" \
          "To fix this issue, use either `with_content` or a block."
        )
      end

      @content =
        if defined?(@__vc_component_instance)
          if defined?(@__vc_content_set_by_with_content)
            @__vc_component_instance.with_content(@__vc_content_set_by_with_content)

            view_context.capture do
              @__vc_component_instance.render_in(view_context)
            end
          elsif defined?(@__vc_content_block)
            view_context.capture do
              # render_in is faster than `parent.render`
              @__vc_component_instance.render_in(view_context, &@__vc_content_block)
            end
          else
            view_context.capture do
              @__vc_component_instance.render_in(view_context)
            end
          end
        elsif defined?(@__vc_content)
          @__vc_content
        elsif defined?(@__vc_content_block)
          view_context.capture(&@__vc_content_block)
        elsif defined?(@__vc_content_set_by_with_content)
          @__vc_content_set_by_with_content
             end

      @content
    end

    def slot_index=(index)
      @__vc_component_instance.__vc__slot_index = index
    end

    # Allow access to public component methods via the wrapper
    #
    # e.g.
    #
    # calling `header.name` (where `header` is a slot) will call `name`
    # on the `HeaderComponent` instance.
    #
    # Where the component may look like:
    #
    # class MyComponent < ViewComponent::Base
    #   has_one :header, HeaderComponent
    #
    #   class HeaderComponent < ViewComponent::Base
    #     def name
    #       @name
    #     end
    #   end
    # end
    #
    def method_missing(symbol, *args, &block)
      @__vc_component_instance.public_send(symbol, *args, &block)
    end

    def html_safe?
      to_s.html_safe?
    end

    def respond_to_missing?(symbol, include_all = false)
      defined?(@__vc_component_instance) && @__vc_component_instance.respond_to?(symbol, include_all)
    end
  end
end
