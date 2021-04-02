# frozen_string_literal: true

require "rails/generators/erb/component_generator"

module Haml
  module Generators
    class ComponentGenerator < Erb::Generators::ComponentGenerator
      source_root File.expand_path("templates", __dir__)
      class_option :sidecar, type: :boolean, default: false

      def copy_view_file
        if !options["inline"]
          template "component.html.haml", destination
        end
      end

      private

      def destination
        if options["sidecar"]
          File.join("app/components", class_path, "#{file_name}_component", "#{file_name}_component.html.haml")
        else
          File.join("app/components", class_path, "#{file_name}_component.html.haml")
        end
      end

      def file_name
        @_file_name ||= super.sub(/_component\z/i, "")
      end
    end
  end
end
