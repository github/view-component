# frozen_string_literal: true

module ViewComponent
  module Generators
    class PreviewGenerator < ::Rails::Generators::NamedBase
      source_root File.expand_path("templates", __dir__)
      class_option :preview_path, type: :string, desc: "Path for previews, required when multiple preview paths are configured", default: ViewComponent::Base.config.generate.preview_path

      argument :attributes, type: :array, default: [], banner: "attribute"
      check_class_collision suffix: "ComponentPreview"

      def create_preview_file
        preview_paths = ViewComponent::Base.config.preview_paths
        optional_path = options[:preview_path]
        return if preview_paths.count > 1 && optional_path.blank?

        path_prefix = if optional_path.present?
          optional_path
        else
          preview_paths.one? ? preview_paths.first : "test/components/previews"
        end

        template "component_preview.rb", File.join(path_prefix, class_path, "#{file_name}_component_preview.rb")
      end

      private

      def file_name
        @_file_name ||= super.sub(/_component\z/i, "")
      end

      def render_signature
        return if attributes.blank?

        attributes.map { |attr| %(#{attr.name}: "#{attr.name}") }.join(", ")
      end
    end
  end
end
