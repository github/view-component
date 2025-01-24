# frozen_string_literal: true

require "test_helper"

module ViewComponent
  class ConfigTest < TestCase
    def setup
      @config = ViewComponent::Config.new
    end

    def test_defaults_are_correct
      assert_equal @config.generate, {preview_path: ""}
      assert_equal @config.preview_controller, "ViewComponentsController"
      assert_equal @config.preview_route, "/rails/view_components"
      assert_equal @config.show_previews_source, false
      assert_equal @config.instrumentation_enabled, false
      assert_equal @config.use_deprecated_instrumentation_name, true
      assert_equal @config.show_previews, true
      assert_equal @config.preview_paths, ["#{Rails.root}/test/components/previews"]
    end

    def test_all_methods_are_documented
      require "yard"
      require "rake"
      YARD::Rake::YardocTask.new do |t|
        t.options = ["--no-output", "--no-stats", "--no-progress"]
      end
      Rake::Task["yard"].execute
      configuration_methods_to_document = YARD::RegistryStore.new.tap do |store|
        store.load!(".yardoc")
      end.get("ViewComponent::Config").meths.select(&:reader?).reject { |meth| meth.name == :config }
      default_options = ViewComponent::Config.defaults.keys
      accessors = ViewComponent::Config.instance_methods(false).reject do |method_name|
        method_name.to_s.end_with?("=") || method_name == :method_missing
      end
      options_defined_on_instance = Set[*default_options, *accessors]
      assert options_defined_on_instance.subset?(Set[*configuration_methods_to_document.map(&:name)]),
        "Not all configuration options are documented: #{options_defined_on_instance.to_a - configuration_methods_to_document.map(&:name)}"
      assert configuration_methods_to_document.map(&:docstring).all?(&:present?),
        "Configuration options are missing docstrings."
    end

    def test_compatibility_module_included
      if ENV["CAPTURE_PATCH_ENABLED"] == "true"
        assert ActionView::Base < ViewComponent::CaptureCompatibility
      else
        refute ActionView::Base < ViewComponent::CaptureCompatibility
      end
    end
  end
end
