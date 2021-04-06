# frozen_string_literal: true

module Rails
  module Generators
    class ComponentGenerator < Rails::Generators::NamedBase
      source_root File.expand_path("templates", __dir__)

      argument :attributes, type: :array, default: [], banner: "attribute"
      check_class_collision suffix: "Component"
      class_option :inline, type: :boolean, default: false

      def create_component_file
        template "component.rb", File.join("app/components", class_path, "#{file_name}_component.rb")
      end

      hook_for :test_framework

      hook_for :preview, type: :boolean

      hook_for :template_engine do |instance, template_engine|
        instance.invoke template_engine, [instance.name]
      end

      private

      def file_name
        @_file_name ||= super.sub(/_component\z/i, "")
      end

      def parent_class
        defined?(ApplicationComponent) ? "ApplicationComponent" : "ViewComponent::Base"
      end

      def initialize_signature
        return if attributes.blank?

        attributes.map { |attr| "#{attr.name}:" }.join(", ")
      end

      def initialize_body
        attributes.map { |attr| "@#{attr.name} = #{attr.name}" }.join("\n    ")
      end

      def initialize_call_method_for_inline?
        options["inline"]
      end
    end
  end
end
