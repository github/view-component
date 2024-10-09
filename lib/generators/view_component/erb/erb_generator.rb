# frozen_string_literal: true

require "rails/generators/erb"
require "generators/view_component/abstract_generator"

module ViewComponent
  module Generators
    class ErbGenerator < Rails::Generators::NamedBase
      include ViewComponent::AbstractGenerator

      source_root File.expand_path("templates", __dir__)
      class_option :sidecar, type: :boolean, default: false
      class_option :inline, type: :boolean, default: false
      class_option :stimulus, type: :boolean, default: false

      def engine_name
        "erb"
      end

      def copy_view_file
        super
      end

      private

      def data_attributes
        if options["stimulus"]
          " data-controller=\"#{stimulus_controller}\""
        end
      end
    end
  end
end
