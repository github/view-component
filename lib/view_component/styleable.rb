# frozen_string_literal: true

require "active_support/concern"
require "view_component/css_module"

module ViewComponent
  # EXPERIMENTAL - This module is subject to change
  # at any time without warning. Use at your own peril!
  #
  # Adds support for sidecar CSS modules.
  # See docs/index.md for directions for use.
  module Styleable
    extend ActiveSupport::Concern

    class_methods do
      # If a sidecar CSS file exists, we compile it onto the
      # component class, storing the resulting CSS and
      # mappings from the original selector names to their
      # hashed equivalents.
      def _after_compile
        return unless css_file_path = _sidecar_files(["css"]).first

        rewrite = ViewComponent::CSSModule.rewrite(
          self.name.demodulize.gsub("Component", ""),
          File.read(css_file_path)
        )

        @css = rewrite[:css]
        @styles = rewrite[:mappings]
      end

      # The compiled CSS.
      #
      # For example:
      #   ".Css_0343d_foo { color: red; }"
      def _css
        ensure_compiled

        @css
      end

      # Hash of mappings from original selector name to
      # the hashed equivalent.
      #
      # For example:
      #   { "foo" => "Css_0343d_foo"}
      def styles
        ensure_compiled

        @styles
      end
    end

    # After component is rendered, attach the style tag
    # that contains the compiled CSS.
    def _after_render
      _style_tag
    end

    # Style tag with compiled CSS.
    #
    # Registers component with current request, preventing
    # the rendering of the style tag more than once for the
    # same component in a single request.
    def _style_tag
      rendered_components = request.params["___rendered_view_components"] ||= Set.new
      rendered_components_identifier = "#{Rails.application.class.name}::#{self.class.name}"

      if !rendered_components.include?(rendered_components_identifier)
        request.params["___rendered_view_components"] << rendered_components_identifier

        content_tag(:style, self.class._css.html_safe)
      end
    end

    # Instance convenience accessor for .styles
    def styles
      self.class.styles
    end
  end
end
