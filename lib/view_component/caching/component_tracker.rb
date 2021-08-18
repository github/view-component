# frozen_string_literal: true

module ViewComponent
  module Caching
    class ComponentTracker < ERBTracker
      def initialize(name, template, view_paths = nil)
        super
        @component_class = name.safe_constantize
      end

      def dependencies
        return [] unless view_component?

        super + templates + relevant_ancestors
      end

      private

      attr_reader :component_class

      def view_component?
        component_class&.ancestors&.include? ViewComponent::Base
      end

      # Returns relevant templates for the component
      def templates
        component_class._sidecar_files(ActionView::Template.template_handler_extensions).map do |path|
          path.gsub(%r{(.*#{Regexp.quote(ViewComponent::Base.view_component_path)}/)|(\..*)}, "")
        end
      end

      # Returns relevant ancestors the component inherits from (if any)
      def relevant_ancestors
        ((component_class.ancestors & ViewComponent::Base.descendants) - [component_class]).
          map(&:to_s)
      end
    end
  end
end
