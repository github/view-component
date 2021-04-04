# frozen_string_literal: true

require "test_helper"

class IntegrationTest < ActionDispatch::IntegrationTest
  def test_rendering_component_in_a_view
    get "/"
    assert_response :success

    assert_select("div", "Foo\n  bar")
  end

  if Rails.version.to_f >= 6.1
    def test_rendering_component_with_template_annotations_enabled
      get "/"
      assert_response :success

      assert_includes response.body, "BEGIN app/components/erb_component.rb"

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

  def test_template_changes_are_not_reflected_on_new_request_when_cache_template_loading_is_true
    # cache_template_loading is set to true on the initializer

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

  def test_template_changes_are_reflected_on_new_request_when_cache_template_loading_is_false
    begin
      old_cache = ViewComponent::CompileCache.cache
      ViewComponent::CompileCache.cache = Set.new
      ActionView::Base.cache_template_loading = false

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
    ensure
      ActionView::Base.cache_template_loading = true
      ViewComponent::CompileCache.cache = old_cache
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

  def test_rendering_component_with_content_for
    get "/content_areas"
    assert_response :success

    assert_select(".title h1", "Hi!")
    assert_select(".body p", "Did you know that 1+1=2?")
    assert_select(".footer h3", "Bye!")
  end

  def test_rendering_component_with_a_partial
    get "/partial"
    assert_response :success

    assert_select("div", "hello,partial world!", count: 2)
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

    cookies[:shown] = true

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

  def test_renders_collections
    get "/products"

    assert_select("h1", text: "Products for sale")
    assert_select("h1", text: "Product", count: 2)
    assert_select("h2", text: "Radio clock")
    assert_select("h2", text: "Mints")
    assert_select("p", text: "Today only", count: 2)
    assert_select("p", text: "Radio clock counter: 1")
    assert_select("p", text: "Mints counter: 2")
  end

  def test_renders_inline_collections
    get "/inline_products"

    assert_select("h1", text: "Product", count: 2)
    assert_select("h2", text: "Radio clock")
    assert_select("h2", text: "Mints")
    assert_select("p", text: "Today only", count: 2)
    assert_select("p", text: "Radio clock counter: 1")
    assert_select("p", text: "Mints counter: 2")
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

    assert_select(".card.mt-4")

    assert_select(".title p", text: "This is my title!")

    assert_select(".subtitle small", text: "This is my subtitle!")

    assert_select(".tab", text: "Tab A")
    assert_select(".tab", text: "Tab B")

    assert_select(".item", count: 3)
    assert_select(".item.highlighted", count: 1)
    assert_select(".item.normal", count: 2)

    assert_select(".footer.text-blue h3", text: "This is the footer")

    title_node = Nokogiri::HTML.fragment(response.body).css(".title").to_html
    expected_title_html = "<div class=\"title\">\n    <p>This is my title!</p>\n  </div>"

    assert_equal(title_node, expected_title_html)
  end

  def test_renders_empty_slot_without_error
    get "/empty_slot"

    assert_response :success
  end

  if Rails.version.to_f >= 6.1
    def test_rendering_component_using_the_render_component_helper_raises_an_error
      error = assert_raises ActionView::Template::Error do
        get "/render_component"
      end
      assert_match /undefined method `render_component'/, error.message
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

  def test_renders_the_preview_example_with_its_own_template_and_a_layout
    get "/rails/view_components/my_component/inside_banner"
    assert_includes response.body, "ViewComponent - Admin - Test"
    assert_select ".banner" do
      assert_select("div", "hello,world!")
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
    assert_select "h1", "This is not a standard place to have a preview template"
    assert_select "input[name=?]", "name"
  end

  def test_renders_an_inline_component_preview_using_a_haml_template
    get "/rails/view_components/inline_component/with_haml"
    assert_select "h1", "Some HAML here"
    assert_select "input[name=?]", "name"
  end

  def test_returns_404_when_preview_does_not_exist
    assert_raises AbstractController::ActionNotFound do
      get "/rails/view_components/missing_preview"
    end
  end

  def test_raises_an_error_if_the_template_is_not_present_and_the_render_with_template_method_is_used_in_the_example
    error = assert_raises ViewComponent::PreviewTemplateError do
      get "/rails/view_components/inline_component/without_template"
    end
    assert_match /preview template for example without_template does not exist/, error.message
  end

  def test_renders_a_preview_template_using_haml_params_from_url_custom_template_and_locals
    get "/rails/view_components/inline_component/with_several_options?form_title=Title from params"

    assert_select "form" do
      assert_select "h1", "Title from params"
      assert_select "input[name=?]", "name"
      assert_select "input[value=?]", "Send this form!"
    end
  end

  def test_renders_link_component_with_active_model
    get "/link_with_active_model"

    assert_select "a[href='/posts/1']"
  end

  def test_renders_link_component_with_path
    get "/link_with_path"

    assert_select "a[href='/posts/1']"
  end
end
