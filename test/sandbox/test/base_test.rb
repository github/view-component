# frozen_string_literal: true

require "test_helper"

class ViewComponent::Base::UnitTest < Minitest::Test
  def skip_templates_parses_all_types_of_paths
    file_path = [
      "/Users/fake.user/path/to.templates/component/test_component.html+phone.erb",
      "/_underscore-dash./component/test_component.html+desktop.slim",
      "/tilda~/component/test_component.html.haml"
    ]
    expected = [
      {variant: :phone, handler: "erb"},
      {variant: :desktop, handler: "slim"},
      {variant: nil, handler: "haml"}
    ]

    compiler = ViewComponent::Compiler.new(ViewComponent::Base)

    ViewComponent::Base.stub(:sidecar_files, file_path) do
      templates = compiler.send(:gather_templates)

      templates.each_with_index do |template, index|
        assert_equal(template[:path], file_path[index])
        if expected[index][:variant].nil?
          # Minitest requires using #assert_nil if asserting nil!
          assert_nil(template[:variant])
        else
          assert_equal(template[:variant], expected[index][:variant])
        end
        assert_equal(template[:handler], expected[index][:handler])
      end
    end
  end

  def test_calling_helpers_outside_render_raises
    component = ViewComponent::Base.new
    err =
      assert_raises ViewComponent::HelpersCalledBeforeRenderError do
        component.helpers
      end
    assert_includes err.message, "can't be used during initialization"
  end

  def test_calling_controller_outside_render_raises
    component = ViewComponent::Base.new
    err =
      assert_raises ViewComponent::ControllerCalledBeforeRenderError do
        component.controller
      end

    assert_includes err.message, "can't be used during initialization"
  end

  def test_sidecar_files
    root = ViewComponent::Engine.root.join("test/sandbox")

    assert_equal(
      [
        "#{root}/app/components/template_and_sidecar_directory_template_component.html.erb",
        "#{root}/app/components/template_and_sidecar_directory_template_component/" \
        "template_and_sidecar_directory_template_component.html.erb"
      ],
      TemplateAndSidecarDirectoryTemplateComponent.sidecar_files(["erb"])
    )

    assert_equal(
      [
        "#{root}/app/components/css_sidecar_file_component.css",
        "#{root}/app/components/css_sidecar_file_component.html.erb"
      ],
      CssSidecarFileComponent.sidecar_files(["css", "erb"])
    )

    assert_equal(
      ["#{root}/app/components/css_sidecar_file_component.css"],
      CssSidecarFileComponent.sidecar_files(["css"])
    )

    assert_equal(
      ["#{root}/app/components/translatable_component.yml"],
      TranslatableComponent.sidecar_files(["yml"])
    )
  end

  def test_does_not_render_additional_newline_with_render_in
    skip unless Rails::VERSION::MAJOR >= 7
    without_template_annotations do
      ActionView::Template::Handlers::ERB.strip_trailing_newlines = true
      rendered_output = Array.new(2) {
        DisplayInlineComponent.new.render_in(ActionController::Base.new.view_context)
      }.join
      assert_includes rendered_output, "<span>Hello, world!</span><span>Hello, world!</span>"
    end
  ensure
    ActionView::Template::Handlers::ERB.strip_trailing_newlines = false if Rails::VERSION::MAJOR >= 7
  end

  def test_evaled_component
    source = <<~RUBY
      class EvaledComponent < ViewComponent::Base
        def initialize(cta: nil, title:)
          @cta = cta
          @title = title
        end
        private

        attr_reader :cta, :title
      end
    RUBY

    eval(source) # rubocop:disable Security/Eval
  end

  def test_no_method_error_does_not_reference_helper_if_view_context_not_present
    exception = assert_raises(NoMethodError) { Class.new(ViewComponent::Base).new.current_user }
    exception_message_regex = Regexp.new <<~MESSAGE.chomp, Regexp::MULTILINE
      undefined method `current_user' for .*

      You may be trying to call a method provided as a view helper. Did you mean `helpers.current_user'?
    MESSAGE
    assert !exception_message_regex.match?(exception.message)
  end

  def test_no_heleprs_error_if_helpers_disabled
    with_helpers_enabled_config(false) do
      exception = assert_raises(NoMethodError) { Class.new(ViewComponent::Base).new.current_user }
      exception_message_regex = Regexp.new <<~MESSAGE.chomp, Regexp::MULTILINE
        undefined method `current_user' for .*

        You may be trying to call a method provided as a view helper. To use it try decalring it using use_helpers :current_user'?
      MESSAGE
      assert !exception_message_regex.match?(exception.message)
    end
  end

  def test_no_method_error_references_helper_if_view_context_present
    view_context = ActionController::Base.new.view_context
    view_context.instance_eval {
      def current_user
        "a user"
      end
    }
    exception = assert_raises(NameError) { ReferencesMethodOnHelpersComponent.new.render_in(view_context) }
    exception_advice = "You may be trying to call a method provided as a view helper. Did you mean `helpers.current_user'?"
    assert exception.message.include?(exception_advice)
  end

  def test_no_method_error_does_not_reference_missing_helper
    view_context = ActionController::Base.new.view_context
    exception = assert_raises(NameError) { ReferencesMethodOnHelpersComponent.new.render_in(view_context) }
    exception_message_regex = Regexp.new <<~MESSAGE.chomp
      You may be trying to call a method provided as a view helper\\. Did you mean `helpers.current_user'\\?$
    MESSAGE
    assert !exception_message_regex.match?(exception.message)
  end

  def test_strict_helpers_enabled
    with_config_option(:strict_helpers_enabled, false) do
      top_level_component_class = Class.new(ViewComponent::Base)
      refute ViewComponent::Base.config.strict_helpers_enabled?, ".strict_helpers_enabled? should be false by default"
      # refute ViewComponent::Base.new.config.strict_helpers_enabled?, "#strict_helpers_enabled? should be false by default"
      Rails.application.config.view_component[:strict_helpers_enabled?] = true
      refute ViewComponent::Base.config.strict_helpers_enabled?, ".strict_helpers_enabled? should not be changed by global config for ViewComponent::Base"
      # refute ViewComponent::Base.new.config.strict_helpers_enabled?, "#strict_helpers_enabled? should not be changed by global config for ViewComponent::Base"
      assert top_level_component_class.component_config.strict_helpers_enabled?, ".strict_helpers_enabled? should inherit from global config"
      assert top_level_component_class.new.component_config.strict_helpers_enabled?, "#strict_helpers_enabled? should inherit from global config"
      inherited_component_class = Class.new(top_level_component_class)
      top_level_component_class.component_config[:strict_helpers_enabled?] = false
      refute inherited_component_class.component_config.strict_helpers_enabled?, ".strict_helpers_enabled? should inherit from its parent"
      refute inherited_component_class.new.component_config.strict_helpers_enabled?, "#strict_helpers_enabled? should inherit from its parent"
    end
  end
end
