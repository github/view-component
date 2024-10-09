# frozen_string_literal: true

require "generators/view_component/erb/erb_generator"

module ViewComponent
  module Generators
    class HamlGenerator < ViewComponent::Generators::ErbGenerator
      include ViewComponent::AbstractGenerator

      source_root File.expand_path("templates", __dir__)
      class_option :sidecar, type: :boolean, default: false

      def engine_name
        "haml"
      end

      def copy_view_file
        super
      end
    end
  end
end
