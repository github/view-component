# frozen_string_literal: true

require "active_support/concern"

module ViewComponent # :nodoc:
  module Previewable
    extend ActiveSupport::Concern

    included do
      # Set a custom default preview layout through app configuration:
      #
      #     config.view_component.default_preview_layout = "component_preview"
      #
      # This affects preview index pages as well as individual component previews
      #
      mattr_accessor :default_preview_layout, instance_writer: false

      # Set the location of component previews through app configuration:
      #
      #     config.view_component.preview_paths << "#{Rails.root}/lib/component_previews"
      #
      mattr_accessor :preview_paths, instance_writer: false

      # TODO: deprecated, remove in v3.0.0
      mattr_accessor :preview_path, instance_writer: false

      # Enable or disable component previews through app configuration:
      #
      #     config.view_component.show_previews = true
      #
      # Defaults to +true+ for development environment
      #
      mattr_accessor :show_previews, instance_writer: false

      # Set the entry route for component previews through app configuration:
      #
      #     config.view_component.preview_route = "/previews"
      #
      # Defaults to +/rails/view_components+ when `show_previews' is enabled
      #
      mattr_accessor :preview_route, instance_writer: false do
        "/rails/view_components"
      end

      # Set the controller to be used for previewing components through app configuration:
      #
      #     config.view_component.preview_controller = "MyPreviewController"
      #
      # Defaults to the provided +ViewComponentsController+
      #
      mattr_accessor :preview_controller, instance_writer: false do
        "ViewComponentsController"
      end
    end
  end
end
