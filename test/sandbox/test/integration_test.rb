# frozen_string_literal: true

require "test_helper"

class IntegrationTest < ActionDispatch::IntegrationTest
  def setup
    ViewComponent::Preview.load_previews
  end

  def test_rendering_component_in_a_view
    get "/"
    assert_response :success

    assert_select("div", "Foo\n  bar")
  end

  if Rails.version.to_f >= 6.1
    def test_rendering_component_with_template_annotations_enabled
      get "/"
      assert_response :success

      assert_includes response.body, "BEGIN app/components/erb_component.html.erb"

      assert_select("div", "Foo\n  bar")
    end
  end

  def test_rendering_component_in_a_controller
    get "/controller_inline_baseline"

    assert_select("div", "bar")
    assert_response :success

    baseline_response = response.body

    get "/controller_inline"
    assert_select("div", "bar")
    assert_response :success

    inline_response = response.body

    assert_includes inline_response, baseline_response
  end

  def test_rendering_component_in_a_controller_with_block
    get "/controller_inline_with_block"

    assert_select("div", "bar")
    assert_select("div#slot", "baz")
    assert_select("div#content", "bam")
    assert_response :success
  end

  def test_template_changes_are_not_reflected_on_new_request_when_cache_template_loading_is_true
    with_template_caching do
      get "/controller_inline"
      assert_select("div", "bar")
      assert_response :success

      modify_file "app/components/controller_inline_component.html.erb", "<div>Goodbye world!</div>" do
        get "/controller_inline"
        assert_select("div", "bar")
        assert_response :success
      end

      get "/controller_inline"
      assert_select("div", "bar")
      assert_response :success
    end
  end

  def test_template_changes_are_reflected_on_new_request_when_cache_template_loading_is_false
    with_new_cache do
      get "/controller_inline"
      assert_select("div", "bar")
      assert_response :success

      modify_file "app/components/controller_inline_component.html.erb", "<div>Goodbye world!</div>" do
        get "/controller_inline"
        assert_select("div", "Goodbye world!")
        assert_response :success
      end

      get "/controller_inline"
      assert_select("div", "bar")
      assert_response :success
    end
  end

  def test_inherited_template_changes_are_reflected_on_new_request_when_cache_template_loading_is_false
    with_new_cache do
      get "/inherited_sidecar"
      assert_select "div", "hello,world!"
      assert_response :success

      modify_file "app/components/my_component.html.erb", "<div>Goodbye world!</div>" do
        get "/inherited_sidecar"
        assert_select "div", "Goodbye world!"
        assert_response :success
      end

      get "/inherited_sidecar"
      assert_select "div", "hello,world!"
      assert_response :success
    end
  end

  def test_inherited_component_with_call_method_does_not_recompile_superclass
    with_new_cache do
      get "/inherited_from_uncompilable_component"
      assert_select "div", "hello world"
      assert_response :success

      compile_method_lines = UncompilableComponent.method(:compile).source.split("\n")
      compile_method_lines.insert(1, 'raise "this should not happen" if self.name == "UncompilableComponent"')
      UncompilableComponent.instance_eval compile_method_lines.join("\n")

      modify_file "app/components/uncompilable_component.html.erb", "<div>Goodbye world!</div>" do
        get "/inherited_from_uncompilable_component"
        assert_select "div", "hello world"
        assert_response :success
      end

      get "/inherited_from_uncompilable_component"
      assert_select "div", "hello world"
      assert_response :success
    end
  end

  def test_helper_changes_are_reflected_on_new_request
    skip if Rails.application.config.cache_classes

    get "/helpers_proxy_component"
    assert_select("div", "Hello helper method")
    assert_response :success

    helper = <<~RUBY
      module MessageHelper
        def message
          "Goodbye world!"
        end
      end
    RUBY
    modify_file "app/helpers/message_helper.rb", helper do
      get "/helpers_proxy_component"
      assert_select("div", "Goodbye world!")
      assert_response :success
    end

    get "/helpers_proxy_component"
    assert_select("div", "Hello helper method")
    assert_response :success
  end

  def test_helper_changes_are_reflected_on_new_request_with_previews
    skip if Rails.application.config.cache_classes

    with_preview_route("/previews") do
      get "/previews/helpers_proxy_component/default"
      assert_select("div", "Hello helper method")
      assert_response :success

      helper = <<~RUBY
        module MessageHelper
          def message
            "Goodbye world!"
          end
        end
      RUBY
      modify_file "app/helpers/message_helper.rb", helper do
        get "/previews/helpers_proxy_component/default"
        assert_select("div", "Goodbye world!")
        assert_response :success
      end

      get "/previews/helpers_proxy_component/default"
      assert_select("div", "Hello helper method")
      assert_response :success
    end
  end

  def test_rendering_component_in_a_controller_using_render_to_string
    get "/controller_inline_baseline"

    assert_select("div", "bar")
    assert_response :success

    baseline_response = response.body

    get "/controller_to_string"
    assert_select("div", "bar")
    assert_response :success

    to_string_response = response.body

    assert_includes to_string_response, baseline_response
  end

  def test_rendering_component_with_content
    get "/content"
    assert_response :success
    assert_select "div.State--green"
    assert_select "div[title='Status: Open']"
    assert_includes response.body, "Open"
  end

  def test_rendering_component_with_a_partial
    get "/partial"
    assert_response :success

    assert_select("div", {text: "hello,partial world!", count: 4})
  end

  def test_rendering_component_without_variant
    get "/variants"
    assert_response :success
    assert_includes response.body, "Default"
  end

  def test_rendering_component_with_tablet_variant
    get "/variants?variant=tablet"
    assert_response :success
    assert_includes response.body, "Tablet"
  end

  def test_rendering_component_several_times_with_different_variants
    get "/variants?variant=tablet"
    assert_response :success
    assert_includes response.body, "Tablet"

    get "/variants?variant=phone"
    assert_response :success
    assert_includes response.body, "Phone"

    get "/variants"
    assert_response :success
    assert_includes response.body, "Default"

    get "/variants?variant=tablet"
    assert_response :success
    assert_includes response.body, "Tablet"

    get "/variants?variant=phone"
    assert_response :success
    assert_includes response.body, "Phone"
  end

  def test_rendering_component_with_caching
    Rails.cache.clear
    ActionController::Base.perform_caching = true

    get "/cached?version=1"
    assert_response :success
    assert_includes response.body, "Cache 1"

    get "/cached?version=2"
    assert_response :success
    assert_includes response.body, "Cache 1"

    ActionController::Base.perform_caching = false
    Rails.cache.clear
  end

  def test_optional_rendering_component_depending_on_request_context
    get "/render_check"
    assert_response :success
    assert_includes response.body, "Rendered"

    cookies[:hide] = true

    get "/render_check"
    assert_response :success
    refute_includes response.body, "Rendered"
  end

  def test_renders_component_preview
    get "/rails/view_components/my_component/default"

    assert_includes response.body, "<div>hello,world!</div>"
  end

  def test_renders_preview_component_default_preview
    get "/rails/view_components/preview_component/default"

    assert_includes response.body, "Click me!"
  end

  def test_renders_preview_component_default_preview_ignoring_params
    get "/rails/view_components/preview_component/default?cta=CTA+from+params"

    assert_includes response.body, "Click me!"

    refute_includes response.body, "CTA from params"
  end

  def test_renders_preview_component_with_cta_preview
    get "/rails/view_components/preview_component/without_cta"

    assert_includes response.body, "More lorem..."
  end

  def test_renders_preview_component_with_content_preview
    get "/rails/view_components/preview_component/with_content"

    assert_includes response.body, "some content"
  end

  def test_renders_preview_component_with_tag_helper_generated_content_preview
    get "/rails/view_components/preview_component/with_tag_helper_in_content"

    assert_includes response.body, "<span>some content</span>"
  end

  def test_renders_preview_component_with_params_preview_with_default_values
    get "/rails/view_components/preview_component/with_params"

    assert_includes response.body, "Default CTA"
    assert_includes response.body, "Default title"
  end

  def test_renders_preview_component_with_params_preview_with_one_param
    get "/rails/view_components/preview_component/with_params?cta=CTA+from+params"

    assert_includes response.body, "CTA from params"
    assert_includes response.body, "Default title"
  end

  def test_renders_preview_component_with_params_preview_with_multiple_params
    get "/rails/view_components/preview_component/with_params?cta=CTA+from+params&title=Title+from+params"

    assert_includes response.body, "CTA from params"
    assert_includes response.body, "Title from params"
  end

  def test_renders_preview_component_with_params_preview_ignoring_unsupported_params
    get "/rails/view_components/preview_component/with_params?cta=CTA+from+params&label=Label+from+params"

    assert_includes response.body, "CTA from params"
    assert_includes response.body, "Default title"

    refute_includes response.body, "Label from params"
  end

  def test_renders_badge_component_open_preview
    get "/rails/view_components/issues/badge_component/open"

    assert_includes response.body, "Open"
  end

  def test_renders_badge_component_closed_preview
    get "/rails/view_components/issues/badge_component/closed"

    assert_includes response.body, "Closed"
  end

  def test_preview_renders
    get "/rails/view_components/preview_component/default"

    assert_select(".preview-component .btn", "Click me!")
  end

  def test_preview_renders_with_layout
    get "/rails/view_components/my_component/default"

    assert_includes response.body, "ViewComponent - Admin - Test"
    assert_select("div", "hello,world!")
  end

  def test_preview_renders_without_layout
    get "/rails/view_components/no_layout/default"

    assert_select("div", "hello,world!")
    refute_includes response.body, "ViewComponent - Test"
  end

  def test_preview_renders_application_s_layout_by_default
    get "/rails/view_components/preview_component/default"

    assert_select "title", "ViewComponent - Test"
  end

  def test_preview_index_renders_rails_application_layout_by_default
    get "/rails/view_components"

    assert_select "title", "Component Previews"
  end

  def test_preview_index_of_a_component_renders_rails_application_layout_by_default
    get "/rails/view_components/preview_component"

    assert_select "title", "Component Previews for preview_component"
  end

  def test_preview_related_views_are_being_rendered_correctly
    get "/rails/view_components"
    assert_select "title", "Component Previews"

    get "/rails/view_components/preview_component/default"
    assert_select "title", "ViewComponent - Test"

    get "/rails/view_components/preview_component"
    assert_select "title", "Component Previews for preview_component"
  end

  def test_preview_from_multiple_preview_paths
    get "/rails/view_components/my_component_lib/default"
    assert_select("div", "hello,world!")
  end

  def test_renders_preview_source_without_template
    get "/rails/view_components/preview_component/default"

    assert_select ".view-component-source-example h2", "Source:"
    assert_select ".view-component-source-example pre.source code"
    assert_select ".language-ruby"
    refute_match "&lt;%=", response.body
    refute_match "%&gt", response.body
  end

  def test_renders_preview_source_with_template_from_layout
    get "/rails/view_components/preview_source_from_layout_component/default_with_template"

    assert_select ".view-component-source-example h2", "Source:"
    assert_select ".view-component-source-example pre.source code"
    assert_select ".language-erb"
    assert_match "&lt;%=", response.body
    assert_match "%&gt", response.body
  end

  def test_renders_collections
    get "/products"

    assert_select("h1", text: "Products for sale")
    assert_select("h1", text: "Product", count: 2)
    assert_select("h2", text: "Radio clock")
    assert_select("h2", text: "Mints")
    assert_select("p", text: "Today only", count: 2)
    assert_select("p", text: "Radio clock counter: 0")
    assert_select("p", text: "Mints counter: 1")
  end

  def test_renders_inline_collections
    get "/inline_products"

    assert_select("h1", text: "Product", count: 2)
    assert_select("h2", text: "Radio clock")
    assert_select("h2", text: "Mints")
    assert_select("p", text: "Today only", count: 2)
    assert_select("p", text: "Radio clock counter: 0")
    assert_select("p", text: "Mints counter: 1")
  end

  def test_renders_the_previews_in_the_configured_route
    with_preview_route("/previews") do
      get "/previews"
      assert_select "title", "Component Previews"

      get "/previews/preview_component/default"
      assert_select "title", "ViewComponent - Test"

      get "/previews/preview_component"
      assert_select "title", "Component Previews for preview_component"
    end
  end

  def test_renders_the_previews_in_the_configured_controller
    with_preview_controller("MyPreviewController") do
      get "/rails/view_components"
      assert_equal response.body, "Custom controller"
    end
  end

  def test_renders_singular_and_collection_slots_with_arguments
    get "/slots"

    assert_select(".title p", text: "This is my title!")

    assert_select(".subtitle small", text: "This is my subtitle!")

    assert_select(".tab", text: "Tab A")
    assert_select(".tab", text: "Tab B")

    assert_select(".item", count: 3)
    assert_select(".item.highlighted", count: 1)
    assert_select(".item.normal", count: 2)

    assert_select(".footer.text-blue h3", text: "This is the footer")
  end

  def test_renders_empty_slot_without_error
    get "/empty_slot"

    assert_response :success
  end

  if Rails.version.to_f >= 6.1
    def test_rendering_component_using_the_render_component_helper_raises_an_error
      error =
        assert_raises ActionView::Template::Error do
          get "/render_component"
        end

      matcher = (RUBY_VERSION >= "3.4") ? /undefined method 'render_component'/ : /undefined method `render_component' for/
      assert_match(matcher, error.message)
    end
  end

  if Rails.version.to_f < 6.1
    def test_rendering_component_using_render_component
      get "/render_component"
      assert_includes response.body, "bar"
    end

    def test_rendering_component_in_a_controller_using_render_component
      get "/controller_inline_render_component"
      assert_includes response.body, "bar"
    end

    def test_rendering_component_in_a_controller_using_render_component_to_string
      get "/controller_to_string_render_component"
      assert_includes response.body, "bar"
    end

    def test_rendering_component_in_preview_using_render_component_and_monkey_patch_disabled
      with_render_monkey_patch_config(false) do
        get "/rails/view_components/monkey_patch_disabled_component/default"
        assert_includes response.body, "<div>hello,world!</div>"
      end
    end
  end

  def test_renders_the_inline_component_preview_examples_with_default_behaviour_and_with_their_own_templates
    get "/rails/view_components/inline_component/default"
    assert_select "input" do
      assert_select "[name=?]", "name"
    end

    get "/rails/view_components/inline_component/inside_form"
    assert_select "form" do
      assert_select "p", "Inside Form"
      assert_select "input[name=?]", "name"
    end

    get "/rails/view_components/inline_component/outside_form"
    assert_select "div" do
      assert_select "p", "Outside Form"
      assert_select "input[name=?]", "name"
    end
  end

  def test_does_not_render_additional_newline
    skip unless Rails::VERSION::MAJOR >= 7
    without_template_annotations do
      ActionView::Template::Handlers::ERB.strip_trailing_newlines = true
      get "/rails/view_components/display_inline_component/with_newline"
      assert_includes response.body, "<span>Hello, world!</span><span>Hello, world!</span>"
    end
  ensure
    ActionView::Template::Handlers::ERB.strip_trailing_newlines = false if Rails::VERSION::MAJOR >= 7
  end

  def test_does_not_render_additional_newline_with_render_in
    skip unless Rails::VERSION::MAJOR >= 7
    without_template_annotations do
      ActionView::Template::Handlers::ERB.strip_trailing_newlines = true
      get "/rails/view_components/display_inline_component/with_newline_render_in"
      assert_includes response.body, "<span>Hello, world!</span><span>Hello, world!</span>"
    end
  ensure
    ActionView::Template::Handlers::ERB.strip_trailing_newlines = false if Rails::VERSION::MAJOR >= 7
  end

  # This test documents a bug that reports an incompatibility with the turbo-rails gem's `turbo_stream` helper.
  # This helper may work if the `capture_compatibility_patch` is enabled.
  # Prefer `tag.turbo_stream` instead if you do not have the patch enabled already.
  def test_render_component_in_turbo_stream
    without_template_annotations do
      get turbo_stream_path, headers: {"HTTP_ACCEPT" => "text/vnd.turbo-stream.html"}
      expected_response_body = <<~TURBOSTREAM
        <turbo-stream action="update" target="area1"><template><span>Hello, world!</span></template></turbo-stream>
      TURBOSTREAM
      if ViewComponent::GlobalConfig.capture_compatibility_patch_enabled
        assert_equal expected_response_body, response.body
      else
        assert_not_equal expected_response_body, response.body
      end
    end
  end

  def test_renders_the_preview_example_with_its_own_template_and_a_layout
    get "/rails/view_components/my_component/inside_banner"
    assert_includes response.body, "ViewComponent - Admin - Test"
    assert_select ".banner" do
      assert_select("div", "hello,world!")
    end
  end

  def test_renders_a_block_passed_to_a_lambda_slot
    get "/rails/view_components/lambda_slot_passthrough_component/default"
    assert_select ".lambda_slot" do
      assert_select ".content", "hello,world!"
    end
  end

  def test_renders_an_inline_component_preview_using_url_params_and_a_template
    get "/rails/view_components/inline_component/with_params?form_title=This is a test form"
    assert_select "form" do
      assert_select "p", "This is a test form"
      assert_select "input[name=?]", "name"
    end
  end

  def test_renders_the_inline_component_using_a_non_standard_located_template
    get "/rails/view_components/inline_component/with_non_standard_template"
    assert_select "h1", "This isn't a standard place to have a preview template"
    assert_select "input[name=?]", "name"
  end

  def test_renders_an_inline_component_preview_using_a_haml_template
    skip if Rails::VERSION::STRING < "6.1"

    get "/rails/view_components/inline_component/with_haml"
    assert_select "h1", "Some HAML here"
    assert_select "input[name=?]", "name"
  end

  def test_returns_404_when_preview_does_not_exist
    assert_raises AbstractController::ActionNotFound do
      get "/rails/view_components/missing_preview"
    end
  end

  def test_renders_a_mix_of_haml_and_erb
    skip if Rails::VERSION::STRING < "6.1"

    get "/nested_haml"
    assert_response :success
    assert_select ".foo > .bar > .baz > .quux > .haml-div"
  end

  def test_raises_an_error_if_the_template_is_not_present_and_the_render_with_template_method_is_used_in_the_example
    error =
      assert_raises ViewComponent::MissingPreviewTemplateError do
        get "/rails/view_components/inline_component/without_template"
      end
    assert_match(/preview template for example without_template doesn't exist/, error.message)
  end

  def test_renders_a_preview_template_using_haml_params_from_url_custom_template_and_locals
    skip if Rails::VERSION::STRING < "6.1"

    get "/rails/view_components/inline_component/with_several_options?form_title=Title from params"

    assert_select "form" do
      assert_select "h1", "Title from params"
      assert_select "input[name=?]", "name"
      assert_select "input[value=?]", "Send this form!"
    end
  end

  def test_renders_a_preview_with_image_path
    get "/rails/view_components/image_path_component/default"

    assert_includes response.body, "images/foo.png"
  end

  def test_sets_the_compiler_mode_in_production_mode
    old_env = Rails.env
    begin
      Rails.env = "production".inquiry

      ViewComponent::Engine.initializers.find { |i| i.name == "compiler mode" }.run
      assert_equal false, ViewComponent::Compiler.development_mode
    ensure
      Rails.env = old_env
      ViewComponent::Engine.initializers.find { |i| i.name == "compiler mode" }.run
    end
  end

  def test_sets_the_compiler_mode_in_development_mode
    Rails.env.stub :development?, true do
      ViewComponent::Engine.initializers.find { |i| i.name == "compiler mode" }.run
      assert_equal true, ViewComponent::Compiler.development_mode
    end

    Rails.env.stub :test?, true do
      ViewComponent::Engine.initializers.find { |i| i.name == "compiler mode" }.run
      assert_equal true, ViewComponent::Compiler.development_mode
    end
  end

  def test_link_to_helper
    get "/link_to_helper"
    assert_select "a > i,span"
  end

  def test_cached_capture
    Rails.cache.clear
    ActionController::Base.perform_caching = true

    get "/cached_capture"
    assert_select ".foo .foo-cached"

    ActionController::Base.perform_caching = false
    Rails.cache.clear
  end

  def test_cached_partial
    Rails.cache.clear
    ActionController::Base.perform_caching = true

    get "/cached_partial"
    assert_select "article.quux"

    ActionController::Base.perform_caching = false
    Rails.cache.clear
  end

  def test_globalconfig_is_proxy_for_rails_app_config
    config_entrypoints = [
      ["Rails application config", Rails.application.config.view_component],
      ["Global config", ViewComponent::GlobalConfig],
      ["ViewComponent::Base's config", ViewComponent::Base.config]
    ]
    config_entrypoints.permutation(2) do |(first_entrypoint_name, first_entrypoint), (second_entrypoint_name, second_entrypoint)|
      first_entrypoint.yield_self do |config|
        {
          generate: config.generate.dup.tap { |c| c.sidecar = true },
          preview_controller: "SomeOtherController",
          preview_route: "/some/other/route",
          show_previews_source: true
        }.each do |option, value|
          with_config_option(option, value, config_entrypoint: config) do
            assert_equal(config.public_send(option), second_entrypoint.public_send(option),
              "#{first_entrypoint_name} should be the same as #{second_entrypoint_name} for #{option.inspect}")
          end
        end
      end
    end
  end

  def test_path_traversal_raises_error
    path = "../../README.md"

    assert_raises ViewComponent::SystemTestControllerNefariousPathError do
      get "/_system_test_entrypoint?file=#{path}"
    end
  end

  def test_unsafe_component
    warnings = capture_warnings { get "/unsafe_component" }
    assert_select("script", false)
    assert(
      warnings.any? { |warning| warning.include?("component rendered HTML-unsafe output") },
      "Rendering UnsafeComponent did not emit an HTML safety warning"
    )
  end

  def test_unsafe_preamble_component
    warnings = capture_warnings { get "/unsafe_preamble_component" }
    assert_select("script", false)
    assert(
      warnings.any? { |warning| warning.include?("component was provided an HTML-unsafe preamble") },
      "Rendering UnsafePreambleComponent did not emit an HTML safety warning"
    )
  end

  def test_unsafe_postamble_component
    warnings = capture_warnings { get "/unsafe_postamble_component" }
    assert_select("script", false)
    assert(
      warnings.any? { |warning| warning.include?("component was provided an HTML-unsafe postamble") },
      "Rendering UnsafePostambleComponent did not emit an HTML safety warning"
    )
  end

  def test_renders_multiple_format_component_as_html
    get "/multiple_formats_component"

    assert_includes response.body, "Hello, HTML!"
  end

  def test_renders_multiple_format_component_as_json
    get "/multiple_formats_component.json"

    assert_equal response.body, "{\"hello\":\"world\"}"
  end

  def test_renders_multiple_format_component_as_css
    get "/multiple_formats_component.css"

    assert_includes response.body, "Hello, CSS!"
  end
end
