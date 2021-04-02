# frozen_string_literal: true

require "rails/generators/erb"

module Erb
  module Generators
    class ComponentGenerator < Base
      source_root File.expand_path("templates", __dir__)
      class_option :sidecar, type: :boolean, default: false
      class_option :inline, type: :boolean, default: false

      def copy_view_file
        template "component.html.erb", destination
      end

      private

      def destination
        if !options["inline"]
          if options["sidecar"]
            File.join("app/components", class_path, "#{file_name}_component", "#{file_name}_component.html.erb")
          else
            File.join("app/components", class_path, "#{file_name}_component.html.erb")
          end
        end
      end

      def file_name
        @_file_name ||= super.sub(/_component\z/i, "")
      end
    end
  end
end
