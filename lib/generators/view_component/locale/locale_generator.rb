# frozen_string_literal: true

require "generators/view_component/abstract_generator"

module ViewComponent
  module Generators
    class LocaleGenerator < ::Rails::Generators::NamedBase
      include ViewComponent::AbstractGenerator

      source_root File.expand_path("templates", __dir__)
      argument :attributes, type: :array, default: [], banner: "attribute"
      class_option :sidecar, type: :boolean, default: false

      def create_locale_file
        if ViewComponent::Base.config.generate.distinct_locale_files
          I18n.available_locales.each do |locale|
            create_file destination(locale), translations_hash([locale]).to_yaml
          end
        else
          create_file destination, translations_hash(I18n.available_locales).to_yaml
        end
      end

      private

      def translations_hash(locales = [:en])
        locales.map { |locale| [locale.to_s, translation_keys] }.to_h
      end

      def translation_keys
        keys = attributes.map(&:name)
        keys = %w[hello] if keys.empty?
        keys.map { |name| [name, name.capitalize] }.to_h
      end

      def destination(locale = nil)
        extension = ".#{locale}" if locale
        if sidecar?
          File.join(component_path, class_path, "#{file_name}_component", "#{file_name}_component#{extension}.yml")
        else
          File.join(component_path, class_path, "#{file_name}_component#{extension}.yml")
        end
      end
    end
  end
end
