# frozen_string_literal: true

require "generators/view_component/abstract_generator"

module ViewComponent
  module Generators
    class RspecGenerator < ::Rails::Generators::NamedBase
      include ViewComponent::AbstractGenerator

      source_root File.expand_path("templates", __dir__)

      def create_test_file
        template "component_spec.rb", File.join(spec_component_path, class_path, "#{file_name}_component_spec.rb")
      end

      private

      def spec_component_path
        return "spec/components" unless ViewComponent::Base.config.generate.use_component_path_for_rspec_tests

        configured_component_path = component_path
        if configured_component_path.start_with?("app#{File::SEPARATOR}")
          _app, *rest_of_path = Pathname.new(configured_component_path).each_filename.to_a
          File.join("spec", *rest_of_path)
        else
          "spec/components"
        end
      end
    end
  end
end
