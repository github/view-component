# frozen_string_literal: true

module ViewComponent
  module Generators
    class TestUnitGenerator < ::Rails::Generators::NamedBase
      source_root File.expand_path("templates", __dir__)
      check_class_collision suffix: "ComponentTest"

      def create_test_file
        template "component_test.rb", File.join("test/components", class_path, "#{file_name}_component_test.rb")
      end

      private

      def file_name
        @_file_name ||= super.sub(/_component\z/i, "")
      end
    end
  end
end
