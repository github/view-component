# frozen_string_literal: true

require "generators/view_component/abstract_generator"

module ViewComponent
  module Generators
    class StimulusGenerator < ::Rails::Generators::NamedBase
      include ViewComponent::AbstractGenerator

      source_root File.expand_path("templates", __dir__)
      class_option :sidecar, type: :boolean, default: false

      def create_stimulus_controller
        template "component_controller.js", destination
      end

      def stimulus_module
        return "stimulus" if legacy_stimulus?

        "@hotwired/stimulus"
      end

      private

      def destination
        if sidecar?
          File.join(component_path, class_path, "#{file_name}_component", "#{file_name}_component_controller.js")
        else
          File.join(component_path, class_path, "#{file_name}_component_controller.js")
        end
      end

      def legacy_stimulus?
        package_json_pathname = Rails.root.join("package.json")
        package_json_pathname.exist? && JSON.parse(package_json_pathname.read).dig("dependencies", "stimulus").present?
      end
    end
  end
end
