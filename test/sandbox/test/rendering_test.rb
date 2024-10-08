# frozen_string_literal: true

require "test_helper"

class RenderingTest < ViewComponent::TestCase
  def test_render_inline
    render_inline(MyComponent.new)

    assert_selector("div", text: "hello,world!")
  end

  def test_render_inline_allocations
    # Stabilize compilation status ahead of testing allocations to simulate rendering
    # performance with compiled component
    ViewComponent::CompileCache.cache.delete(MyComponent)
    MyComponent.ensure_compiled

    assert_allocations("3.4.0" => 108, "3.3.5" => 116, "3.3.0" => 129, "3.2.5" => 115, "3.1.6" => 115, "3.0.7" => 125) do
      render_inline(MyComponent.new)
    end

    assert_selector("div", text: "hello,world!")
  end

  def test_render_in_view_context
    render_in_view_context { render(MyComponent.new) }

    assert_selector("div", text: "hello,world!")
  end

  def test_render_in_view_context_forwards_arguments
    @foo = "foo"
    @bar = "bar"

    render_in_view_context(@foo, bar: @bar) do |foo, bar:|
      render(MyComponent.new) { foo + bar }
    end

    assert_text "hello,world!\nfoobar"
  end

  def test_render_inline_returns_nokogiri_fragment
    assert_includes render_inline(MyComponent.new).css("div").to_html, "hello,world!"
  end

  def test_render_inline_sets_rendered_content
    render_inline(MyComponent.new)

    assert_includes rendered_content, "hello,world!"
  end

  def test_child_component
    render_inline(ChildComponent.new)

    assert_selector("div", text: "hello,world!")
  end

  def test_renders_content_from_block
    render_inline(WrapperComponent.new) do
      "content"
    end

    assert_selector("span", text: "content")
  end

  def test_raise_error_when_content_already_set
    error =
      assert_raises ViewComponent::DuplicateContentError do
        render_inline(WrapperComponent.new.with_content("setter content")) do
          "block content"
        end
      end

    assert_includes error.message, "It looks like a block was provided after calling"
  end

  def test_renders_content_given_as_argument
    render_inline(WrapperComponent.new.with_content("from arg"))

    assert_selector("span", text: "from arg")
  end

  def test_raises_error_when_with_content_is_called_without_any_values
    exception =
      assert_raises ViewComponent::NilWithContentError do
        WrapperComponent.new.with_content(nil)
      end

    assert_includes exception.message, "No content provided to"
  end

  def test_render_without_template
    render_inline(InlineComponent.new)

    assert_predicate InlineComponent, :compiled?
    assert_selector("input[type='text'][name='name']")
  end

  def test_render_child_without_template
    render_inline(InlineChildComponent.new)

    assert_predicate InlineChildComponent, :compiled?
    assert_selector("input[type='text'][name='name']")
  end

  def test_render_empty_component
    assert_nothing_raised do
      render_inline(EmptyComponent.new)
    end
  end

  def test_renders_slim_template
    render_inline(SlimComponent.new(message: "bar")) { "foo" }

    assert_text("foo")
    assert_text("bar")
  end

  def test_renders_haml_with_html_formatted_slot
    skip if Rails::VERSION::STRING < "6.1"

    render_inline(HamlHtmlFormattedSlotComponent.new)

    assert_selector("p", text: "HTML Formatted one")
    assert_selector("p", text: "HTML Formatted many", count: 2)

    # ensure the content isn't rendered twice (once escaped, once not)
    assert_no_text "<p>HTML Formatted one</p>"
    assert_no_text "<p>HTML Formatted many</p>"
  end

  def test_renders_slim_with_many_slots
    render_inline(SlimRendersManyComponent.new) do |c|
      c.with_slim_component(message: "Bar A") do
        "Foo A "
      end
      c.with_slim_component(message: "Bar B") do
        "Foo B "
      end
    end

    assert_selector(".slim-div", text: "Foo A Bar A")
    assert_selector(".slim-div", text: "Foo B Bar B")
  end

  def test_renders_slim_with_html_formatted_slot
    render_inline(SlimHtmlFormattedSlotComponent.new)

    assert_selector("p", text: "HTML Formatted")
  end

  def test_renders_slim_escaping_dangerous_html_assign
    render_inline(SlimWithUnsafeHtmlComponent.new)

    refute_selector("script")
    assert_selector(".slim-div", text: "<script>alert('xss')</script>")
  end

  def test_renders_haml_template
    render_inline(HamlComponent.new(message: "bar")) { "foo" }

    assert_text("foo")
    assert_text("bar")
  end

  def test_render_jbuilder_template
    with_format(:json) do
      render_inline(JbuilderComponent.new(message: "bar")) { "foo" }
    end

    assert_text("foo")
    assert_text("bar")
  end

  def test_renders_button_to_component
    old_value = ActionController::Base.allow_forgery_protection
    ActionController::Base.allow_forgery_protection = true

    render_inline(ButtonToComponent.new) { "foo" }

    assert_selector("form[class='button_to'][action='/'][method='post']")
    assert_selector("input[type='hidden'][name='authenticity_token']", visible: false)

    ActionController::Base.allow_forgery_protection = old_value
  end

  def test_renders_button_to_component_with_strict_helpers
    with_helpers_enabled_config(false) do
      old_value = ActionController::Base.allow_forgery_protection
      ActionController::Base.allow_forgery_protection = true

      render_inline(ButtonToComponent.new) { "foo" }

      assert_selector("form[class='button_to'][action='/'][method='post']")
      assert_selector("input[type='hidden'][name='authenticity_token']", visible: false)

      ActionController::Base.allow_forgery_protection = old_value
    end
  end

  def test_renders_component_with_variant
    with_variant :phone do
      render_inline(VariantsComponent.new)

      assert_text("Phone")
    end
  end

  def test_renders_component_with_variant_containing_a_dash
    with_variant :"mini-watch" do
      render_inline(VariantsComponent.new)

      assert_text("Mini Watch with dash")
    end
  end

  def test_renders_component_with_variant_containing_a_dot
    with_variant :"mini.watch" do
      render_inline(VariantsComponent.new)

      assert_text("Mini Watch with dot")
    end
  end

  def test_renders_default_template_when_variant_template_is_not_present
    with_variant :variant_without_template do
      render_inline(VariantsComponent.new)

      assert_text("Default")
    end
  end

  def test_renders_inline_variant_template_when_variant_template_is_not_present
    with_variant :inline_variant do
      render_inline(InlineVariantComponent.new)

      assert_predicate InlineVariantComponent, :compiled?
      assert_selector("input[type='text'][name='inline_variant']")
    end
  end

  def test_renders_child_inline_variant_when_variant_template_is_not_present
    with_variant :inline_variant do
      render_inline(InlineVariantChildComponent.new)

      assert_predicate InlineVariantChildComponent, :compiled?
      assert_selector("input[type='text'][name='inline_variant']")
    end
  end

  def test_renders_child_inline_variant_when_variant_template_is_present
    with_variant :inline_variant do
      render_inline(InlineVariantChildWithTemplateComponent.new)

      assert_selector("div", text: "Template")
    end
  end

  def test_renders_erb_template
    render_inline(ErbComponent.new(message: "bar")) { "foo" }

    assert_text("foo")
    assert_text("bar")
  end

  def test_renders_partial_template
    render_inline(PartialComponent.new)

    assert_text("hello,partial world!", count: 3)
  end

  def test_renders_content_for_template
    render_inline(ContentForComponent.new)

    assert_text("Hello content for")
  end

  def test_renders_helper_method_through_proxy
    render_inline(HelpersProxyComponent.new)

    assert_text("Hello helper method")
  end

  def test_renders_helper_method_within_nested_component
    render_inline(ContainerComponent.new)

    assert_text("Hello helper method")
  end

  def test_renders_helper_method_within_nested_component_with_disabled_monkey_patch
    with_render_monkey_patch_config(false) do
      render_inline(ContainerComponent.new)
      assert_text("Hello helper method")
    end
  end

  def test_renders_path_helper
    render_inline(PathComponent.new)

    assert_text("/")
  end

  def test_renders_nested_path_helper
    render_inline(PathContainerComponent.new)

    assert_text("/")
  end

  def test_renders_url_helper
    render_inline(UrlComponent.new)

    assert_text("http://test.host/")
  end

  def test_renders_another_component
    render_inline(AnotherComponent.new)

    assert_text("hello,world!")
  end

  def test_renders_component_with_css_sidecar
    render_inline(CssSidecarFileComponent.new)

    assert_text("hello, world!")
  end

  def test_renders_component_with_sidecar_directory
    render_inline(SidecarDirectoryComponent.new)

    assert_text("hello, world!")
  end

  def test_renders_component_with_request_context
    render_inline(RequestComponent.new)

    assert_text("0.0.0.0")
  end

  def test_renders_component_without_format
    render_inline(NoFormatComponent.new)

    assert_text("hello,world!")
  end

  def test_renders_component_with_asset_url
    component = AssetComponent.new
    assert_match(%r{http://assets.example.com/assets/application-\w+.css}, render_inline(component).text)

    component.config.asset_host = nil
    assert_match(%r{/assets/application-\w+.css}, render_inline(component).text)

    component.config.asset_host = "http://assets.example.com"
    assert_match(%r{http://assets.example.com/assets/application-\w+.css}, render_inline(component).text)

    component.config.asset_host = "assets.example.com"
    assert_match(%r{http://assets.example.com/assets/application-\w+.css}, render_inline(component).text)
  end

  def test_renders_component_with_asset_url_with_strict_helpers
    with_helpers_enabled_config(false) do
      component = AssetComponent.new
      assert_match(%r{http://assets.example.com/assets/application-\w+.css}, render_inline(component).text)

      component.config.asset_host = nil
      assert_match(%r{/assets/application-\w+.css}, render_inline(component).text)

      component.config.asset_host = "http://assets.example.com"
      assert_match(%r{http://assets.example.com/assets/application-\w+.css}, render_inline(component).text)

      component.config.asset_host = "assets.example.com"
      assert_match(%r{http://assets.example.com/assets/application-\w+.css}, render_inline(component).text)
    end
  end

  def test_template_changes_are_not_reflected_if_cache_is_not_cleared
    render_inline(MyComponent.new)

    assert_text("hello,world!")

    modify_file "app/components/my_component.html.erb", "<div>Goodbye world!</div>" do
      render_inline(MyComponent.new)

      assert_no_text("Goodbye world!")
    end

    render_inline(MyComponent.new)
  end

  def test_that_it_has_a_version_number
    refute_nil ::ViewComponent::VERSION::MAJOR
    assert_kind_of Integer, ::ViewComponent::VERSION::MAJOR
    refute_nil ::ViewComponent::VERSION::MINOR
    assert_kind_of Integer, ::ViewComponent::VERSION::MINOR
    refute_nil ::ViewComponent::VERSION::PATCH
    assert_kind_of Integer, ::ViewComponent::VERSION::PATCH

    version_string = [
      ::ViewComponent::VERSION::MAJOR,
      ::ViewComponent::VERSION::MINOR,
      ::ViewComponent::VERSION::PATCH,
      ::ViewComponent::VERSION::PRE
    ].compact.join(".")
    assert_equal version_string, ::ViewComponent::VERSION::STRING
  end

  def test_renders_component_with_translations
    render_inline(TranslationsComponent.new)

    assert_selector("h1", text: I18n.t("translations_component.title"))
    assert_selector("h2", text: I18n.t("translations_component.subtitle"))
  end

  def test_renders_component_with_initializer_translations
    err =
      assert_raises ViewComponent::TranslateCalledBeforeRenderError do
        render_inline(InitializerTranslationsComponent.new)
      end
    assert_includes err.message, "can't be used during initialization"
  end

  def test_renders_component_with_rb_in_its_name
    render_inline(EditorbComponent.new)

    assert_text("Editorb")
  end

  def test_conditional_rendering
    render_inline(ConditionalRenderComponent.new(should_render: true))

    assert_text("component was rendered")

    render_inline(ConditionalRenderComponent.new(should_render: false))

    assert_no_text("component was rendered")
  end

  def test_conditional_rendering_if_content_provided
    render_inline(ConditionalContentComponent.new)

    refute_component_rendered

    render_inline(ConditionalContentComponent.new) do
      "Content"
    end

    assert_component_rendered
    assert_text("Content")
  end

  def test_assert_select
    render_inline(MyComponent.new)

    assert_selector("div")
  end

  def test_validations_component
    exception =
      assert_raises ActiveModel::ValidationError do
        render_inline(ValidationsComponent.new)
      end

    assert_includes exception.message, "Validation failed: Content"
  end

  def test_compiles_unrendered_component
    # The UnreferencedComponent will get compiled at boot,
    # but that might have been thrown away if code-reloading is enabled
    skip unless Rails.env.cache_classes?

    assert UnreferencedComponent.compiled?
  end

  def test_compiles_components_without_initializers
    # MissingInitializerComponent will get compiled at boot,
    # but that might have been thrown away if code-reloading is enabled
    skip unless Rails.env.cache_classes?

    assert MissingInitializerComponent.compiled?
  end

  def test_renders_when_initializer_is_not_defined
    render_inline(MissingInitializerComponent.new)

    assert_selector("div", text: "Hello, world!")
  end

  def test_raises_error_when_sidecar_template_is_missing
    exception =
      assert_raises ViewComponent::TemplateError do
        render_inline(MissingTemplateComponent.new)
      end

    assert_includes(
      exception.message,
      "Couldn't find a template file or inline render method for MissingTemplateComponent"
    )
  end

  def test_raises_error_when_more_than_one_sidecar_template_is_present
    error =
      assert_raises ViewComponent::TemplateError do
        render_inline(TooManySidecarFilesComponent.new)
      end

    assert_includes error.message, "More than one HTML template found for TooManySidecarFilesComponent."
  end

  def test_raises_error_when_more_than_one_sidecar_template_for_a_variant_is_present
    error =
      assert_raises ViewComponent::TemplateError do
        render_inline(TooManySidecarFilesForVariantComponent.new)
      end

    assert_includes(
      error.message,
      "More than one HTML template found for variant `test` for TooManySidecarFilesForVariantComponent"
    )

    assert_includes(
      error.message,
      "More than one HTML template found for variant `testing` for TooManySidecarFilesForVariantComponent"
    )
  end

  def test_raise_error_when_default_template_file_and_inline_default_call_exist
    error =
      assert_raises ViewComponent::TemplateError do
        render_inline(DefaultTemplateAndInlineDefaultTemplateComponent.new)
      end

    assert_includes(
      error.message,
      "Template file and inline render method found for DefaultTemplateAndInlineDefaultTemplateComponent."
    )
  end

  def test_raise_error_when_variant_template_file_and_inline_variant_call_exist
    error =
      assert_raises ViewComponent::TemplateError do
        with_variant :phone do
          render_inline(VariantTemplateAndInlineVariantTemplateComponent.new)
        end
      end

    assert_includes(
      error.message,
      "ViewComponent::Template:"
    )

    assert_includes(
      error.message,
      "Template file and inline render method found for variant 'phone' in " \
      "VariantTemplateAndInlineVariantTemplateComponent."
    )
  end

  def test_raise_error_when_variant_template_file_and_inline_variant_collide
    error =
      assert_raises ViewComponent::TemplateError do
        with_variant :"mini-watch" do
          render_inline(VariantTemplateAndInlineVariantCollisionComponent.new)
        end
      end

    assert_includes(
      error.message,
      "Colliding templates 'mini-watch' and 'mini__watch' found in " \
      "VariantTemplateAndInlineVariantCollisionComponent."
    )
  end

  def test_raise_error_when_variant_template_files_collide
    error =
      assert_raises ViewComponent::TemplateError do
        with_variant :"mini-watch" do
          render_inline(VariantTemplatesCollisionComponent.new)
        end
      end

    assert_includes(
      error.message,
      "Colliding templates 'mini-watch' and 'mini__watch' found in VariantTemplatesCollisionComponent." \
    )
  end

  def test_raise_error_when_template_file_and_sidecar_directory_template_exist
    error =
      assert_raises ViewComponent::TemplateError do
        render_inline(TemplateAndSidecarDirectoryTemplateComponent.new)
      end

    assert_includes(
      error.message,
      "More than one HTML template found for TemplateAndSidecarDirectoryTemplateComponent."
    )
  end

  def test_with_custom_test_controller
    with_controller_class CustomTestControllerController do
      render_inline(CustomTestControllerComponent.new)

      assert_text("foo")
    end
  end

  def test_uses_default_form_builder
    with_controller_class DefaultFormBuilderController do
      render_inline(DefaultFormBuilderComponent.new)

      assert_text("changed by default form builder")
    end
  end

  def test_backtrace_returns_correct_file_and_line_number
    error =
      assert_raises NameError do
        render_inline(ExceptionInTemplateComponent.new)
      end

    component_error_index = (Rails::VERSION::STRING < "8.0") ? 0 : 1
    assert_match %r{app/components/exception_in_template_component\.html\.erb:2}, error.backtrace[component_error_index]
  end

  def test_render_collection
    products = [OpenStruct.new(name: "Radio clock"), OpenStruct.new(name: "Mints")]
    render_inline(ProductComponent.with_collection(products, notice: "On sale"))

    assert_selector("h1", text: "Product", count: 2)
    assert_selector("h2.first", text: "Radio clock")
    assert_selector("h2:not(.first)", text: "Mints")
    assert_selector("p", text: "On sale", count: 2)
    assert_selector("p", text: "Radio clock counter: 0")
    assert_selector("p", text: "Mints counter: 1")
  end

  def test_render_collection_custom_collection_parameter_name
    coupons = [OpenStruct.new(percent_off: 20), OpenStruct.new(percent_off: 50)]
    render_inline(ProductCouponComponent.with_collection(coupons))

    assert_selector("h3", text: "20%")
    assert_selector("h3", text: "50%")
  end

  def test_render_collection_custom_collection_parameter_name_counter
    photos = [
      OpenStruct.new(title: "Flowers", caption: "Yellow flowers", url: "https://example.com/flowers.jpg"),
      OpenStruct.new(title: "Mountains", caption: "Mountains at sunset", url: "https://example.com/mountains.jpg")
    ]
    render_inline(CollectionCounterComponent.with_collection(photos))

    assert_selector("figure[data-index=0]", {count: 1})
    assert_selector("figcaption", text: "Photo.0 - Yellow flowers")

    assert_selector("figure[data-index=1]", {count: 1})
    assert_selector("figcaption", text: "Photo.1 - Mountains at sunset")
  end

  def test_render_collection_custom_collection_parameter_name_iteration
    photos = [
      OpenStruct.new(title: "Flowers", caption: "Yellow flowers", url: "https://example.com/flowers.jpg"),
      OpenStruct.new(title: "Mountains", caption: "Mountains at sunset", url: "https://example.com/mountains.jpg")
    ]
    render_inline(CollectionIterationComponent.with_collection(photos))

    assert_selector("figure.first[data-index=0]", {count: 1})
    assert_selector("figcaption", text: "Photo.1 - Yellow flowers")

    assert_selector("figure[data-index=1]:not(.first)", {count: 1})
    assert_selector("figcaption", text: "Photo.2 - Mountains at sunset")
  end

  def test_render_collection_custom_collection_parameter_name_iteration_extend_other_component
    photos = [
      OpenStruct.new(title: "Flowers", caption: "Yellow flowers", url: "https://example.com/flowers.jpg"),
      OpenStruct.new(title: "Mountains", caption: "Mountains at sunset", url: "https://example.com/mountains.jpg")
    ]
    render_inline(CollectionIterationExtendComponent.with_collection(photos))

    assert_selector("figure.first[data-index=0]", {count: 1})
    assert_selector("figcaption", text: "Photo.1 - Yellow flowers")

    assert_selector("figure[data-index=1]:not(.first)", {count: 1})
    assert_selector("figcaption", text: "Photo.2 - Mountains at sunset")
  end

  def test_render_collection_custom_collection_parameter_name_iteration_extend_other_component_override
    photos = [
      OpenStruct.new(title: "Flowers", caption: "Yellow flowers", url: "https://example.com/flowers.jpg"),
      OpenStruct.new(title: "Mountains", caption: "Mountains at sunset", url: "https://example.com/mountains.jpg")
    ]
    render_inline(CollectionIterationExtendOverrideComponent.with_collection(photos))

    assert_selector("figure.first[data-index=0]", {count: 1})
    assert_selector("figcaption", text: "Photo.1 - Yellow flowers")

    assert_selector("figure[data-index=1]:not(.first)", {count: 1})
    assert_selector("figcaption", text: "Photo.2 - Mountains at sunset")
  end

  def test_render_collection_nil_and_empty_collection
    [nil, []].each do |collection|
      render_inline(ProductComponent.with_collection(collection, notice: "On sale"))

      assert_no_text("Products")
    end
  end

  def test_render_collection_missing_collection_object
    exception =
      assert_raises ViewComponent::InvalidCollectionArgumentError do
        render_inline(ProductComponent.with_collection("foo"))
      end

    assert_includes exception.message, "Make sure it responds to `to_ary`"
  end

  def test_render_collection_missing_arg
    products = [OpenStruct.new(name: "Radio clock"), OpenStruct.new(name: "Mints")]
    exception =
      assert_raises ArgumentError do
        render_inline(ProductComponent.with_collection(products))
      end

    assert_match(/missing keyword/, exception.message)
    assert_match(/notice/, exception.message)
  end

  def test_render_single_item_from_collection
    product = OpenStruct.new(name: "Mints")
    render_inline(ProductComponent.new(product: product, notice: "On sale"))

    assert_selector("h1", text: "Product", count: 1)
    assert_selector("h2", text: "Mints")
    assert_selector("p", text: "On sale", count: 1)
  end

  def test_collection_component_missing_parameter_name
    assert_raises ViewComponent::MissingCollectionArgumentError do
      render_inline(MissingCollectionParameterNameComponent.with_collection([]))
    end
  end

  def test_collection_component_missing_default_parameter_name
    assert_raises ViewComponent::MissingCollectionArgumentError do
      render_inline(
        MissingDefaultCollectionParameterComponent.with_collection([OpenStruct.new(name: "Mints")])
      )
    end
  end

  def test_collection_component_missing_custom_parameter_name_with_activemodel
    assert_raises ViewComponent::MissingCollectionArgumentError do
      render_inline(
        MissingCollectionParameterWithActiveModelComponent.with_collection([OpenStruct.new(name: "Mints")])
      )
    end
  end

  def test_collection_component_present_custom_parameter_name_with_activemodel
    assert_nothing_raised do
      render_inline(
        CollectionParameterWithActiveModelComponent.with_collection([OpenStruct.new(name: "Mints")])
      )
    end
  end

  def test_component_with_invalid_parameter_names
    with_new_cache do
      exception =
        assert_raises ViewComponent::ReservedParameterError do
          InvalidParametersComponent.compile(raise_errors: true)
        end

      assert_match(/InvalidParametersComponent initializer can't accept the parameter/, exception.message)
    end
  end

  def test_component_with_invalid_named_parameter_names
    with_new_cache do
      exception =
        assert_raises ViewComponent::ReservedParameterError do
          InvalidNamedParametersComponent.compile(raise_errors: true)
        end

      assert_match(
        /InvalidNamedParametersComponent initializer can't accept the parameter `content`/,
        exception.message
      )
    end
  end

  def test_collection_component_with_trailing_comma_attr_reader
    exception =
      assert_raises ViewComponent::EmptyOrInvalidInitializerError do
        render_inline(
          ProductReaderOopsComponent.with_collection(["foo"])
        )
      end

    assert_match(/ProductReaderOopsComponent initializer is empty or invalid/, exception.message)
  end

  def test_renders_component_using_rails_config
    render_inline(RailsConfigComponent.new)

    assert_text("http://assets.example.com")
  end

  def test_renders_component_using_rails_config_with_strict_helpers
    with_helpers_enabled_config(false) do
      render_inline(RailsConfigComponent.new)

      assert_text("http://assets.example.com")
    end
  end

  def test_inherited_component_inherits_template
    render_inline(InheritedTemplateComponent.new)

    assert_selector("div", text: "hello,world!")
  end

  def test_inherited_component_overrides_inherits_template
    render_inline(InheritedWithOwnTemplateComponent.new)

    assert_selector("div", text: "hello, my own template")
  end

  def test_inherited_inline_component_inherits_inline_method
    render_inline(InlineInheritedComponent.new)

    assert_predicate InlineInheritedComponent, :compiled?
    assert_selector("input[type='text'][name='name']")
  end

  def test_renders_ivar_named_variant
    render_inline(VariantIvarComponent.new(variant: "foo"))

    assert_text("foo")
  end

  def test_does_not_render_passed_in_content_if_render_is_false
    start_time = Time.now

    render_inline ConditionalRenderComponent.new(should_render: false) do |c|
      c.render SleepComponent.new(seconds: 5)
    end

    total = Time.now - start_time

    assert total < 1
  end

  def test_collection_parameter_does_not_require_compile
    dynamic_component =
      Class.new(ViewComponent::Base) do
        with_collection_parameter :greeting

        def initialize(greeting = "hello world")
          @greeting = greeting
        end

        def call
          content_tag :h1, @greeting
        end
      end

    # Necessary because anonymous classes don't have a `name` property
    Object.const_set(:MY_COMPONENT, dynamic_component)

    render_inline MY_COMPONENT.new
    assert_selector "h1", text: "hello world"

    render_inline MY_COMPONENT.with_collection(["hello world", "hello view component"])
    assert_selector "h1", text: "hello world"
    assert_selector "h1", text: "hello view component"
  ensure
    Object.send(:remove_const, :MY_COMPONENT)
  end

  def test_with_request_url
    with_request_url "/" do
      render_inline UrlForComponent.new
      assert_text "/?key=value"
    end

    with_request_url "/products" do
      render_inline UrlForComponent.new
      assert_text "/products?key=value"
    end

    with_request_url "/products" do
      assert_equal "/products", vc_test_request.path
    end
  end

  def test_with_request_url_with_query_parameters
    with_request_url "/?mykey=myvalue" do
      render_inline UrlForComponent.new
      assert_text "/?key=value&mykey=myvalue"
    end

    with_request_url "/?mykey=myvalue&otherkey=othervalue" do
      render_inline UrlForComponent.new
      assert_text "/?key=value&mykey=myvalue&otherkey=othervalue"
    end

    with_request_url "/products?mykey=myvalue" do
      render_inline UrlForComponent.new
      assert_text "/products?key=value&mykey=myvalue"
    end

    with_request_url "/products?mykey=myvalue&otherkey=othervalue" do
      assert_equal "/products", vc_test_request.path
      assert_equal "mykey=myvalue&otherkey=othervalue", vc_test_request.query_string
      assert_equal "/products?mykey=myvalue&otherkey=othervalue", vc_test_request.fullpath
      assert_instance_of ActiveSupport::HashWithIndifferentAccess, vc_test_request.query_parameters
    end

    with_request_url "/products?mykey[mynestedkey]=myvalue" do
      assert_equal({"mynestedkey" => "myvalue"}, vc_test_request.parameters["mykey"])
    end
  end

  def test_with_request_url_with_host
    with_request_url "/", host: "app.example.com" do
      render_inline UrlForComponent.new(only_path: false)
      assert_text "http://app.example.com/?key=value"
    end

    with_request_url "/products", host: "app.example.com" do
      render_inline UrlForComponent.new(only_path: false)
      assert_text "http://app.example.com/products?key=value"
    end

    with_request_url "/products", host: "app.example.com" do
      assert_equal "app.example.com", vc_test_request.host
    end
  end

  def test_components_share_helpers_state
    PartialHelper::State.reset

    render_inline PartialHelperComponent.new

    assert_equal 1, PartialHelper::State.calls
  end

  def test_output_preamble
    render_inline(BeforeRenderComponent.new)

    assert_text("Well, Hello!")
  end

  def test_output_postamble
    render_inline(AfterRenderComponent.new)

    assert_text("Hello, World!")
  end

  def test_output_preamble_and_postamble
    render_inline(BeforeAndAfterRenderComponent.new)

    assert_text("Well, Hello, World!")
  end

  def test_compilation_in_development_mode
    with_compiler_development_mode(true) do
      with_new_cache do
        render_inline(MyComponent.new)
        assert_selector("div", text: "hello,world!")
      end
    end
  end

  def test_compilation_in_production_mode
    with_compiler_development_mode(false) do
      with_new_cache do
        render_inline(MyComponent.new)
        assert_selector("div", text: "hello,world!")
      end
    end
  end

  def test_multithread_render
    ViewComponent::CompileCache.cache.delete(MyComponent)
    Rails.env.stub :test?, true do
      threads = 100.times.map do
        Thread.new do
          render_inline(MyComponent.new)

          assert_selector("div", text: "hello,world!")
        end
      end

      threads.map(&:join)
    end
  end

  def test_concurrency_deadlock_cache
    with_compiler_development_mode(true) do
      with_new_cache do
        render_inline(ContentEvalComponent.new) do
          ViewComponent::CompileCache.invalidate!
          render_inline(ContentEvalComponent.new)
        end
      end
    end
  end

  def test_multiple_inline_renders_of_the_same_component
    component = ErbComponent.new(message: "foo")
    render_inline(InlineRenderComponent.new(items: [component, component]))
    assert_selector("div", text: "foo", count: 2)
  end

  def test_inherited_component_renders_when_lazy_loading
    # Simulate lazy loading by manually removing the classes in question. This will completely
    # undo the changes made by self.class.compile and friends, forcing a compile the next time
    # #render_template_for is called. This shouldn't be necessary except in the test environment,
    # since eager loading is turned on here.
    Object.send(:remove_const, :MyComponent) if defined?(MyComponent)
    Object.send(:remove_const, :InheritedWithOwnTemplateComponent) if defined?(InheritedWithOwnTemplateComponent)

    load "test/sandbox/app/components/my_component.rb"
    load "test/sandbox/app/components/inherited_with_own_template_component.rb"

    render_inline(MyComponent.new)
    assert_selector("div", text: "hello,world!")

    render_inline(InheritedWithOwnTemplateComponent.new)
    assert_selector("div", text: "hello, my own template")
  end

  def test_render_parent
    render_inline(SuperComponent.new)

    assert_selector(".base-component", count: 1)
    assert_selector(".derived-component", count: 1) do |derived|
      derived.assert_selector(".base-component", count: 1)
    end
  end

  def test_child_components_can_render_parent
    render_inline(Level3Component.new)

    assert_selector(".level3-component.base .level2-component.base .level1-component")
  end

  def test_variant_propagates_to_parent
    with_variant :variant do
      render_inline(Level3Component.new)
    end

    assert_selector ".level3-component.variant .level2-component.variant .level1-component"
  end

  def test_child_components_fall_back_to_default_variant
    with_variant :non_existent_variant do
      render_inline(Level3Component.new)
    end

    assert_selector ".level3-component.base .level2-component.base .level1-component"
  end

  def test_child_components_can_render_parent_with_inline_templates
    render_inline(InlineLevel3Component.new)

    assert_selector(".level3-component.base .level2-component.base .level1-component")
  end

  def test_variant_propagates_to_parent_with_inline_templates
    with_variant :variant do
      render_inline(InlineLevel3Component.new)
    end

    assert_selector ".level3-component.variant .level2-component.variant .level1-component"
  end

  def test_child_components_fall_back_to_default_variant_with_inline_templates
    with_variant :non_existent_variant do
      render_inline(InlineLevel3Component.new)
    end

    assert_selector ".level3-component.base .level2-component.base .level1-component"
  end

  def test_component_renders_without_trailing_whitespace
    template = File.read(Rails.root.join("app/components/trailing_whitespace_component.html.erb"))
    assert template =~ /\s+\z/, "Template does not contain any trailing whitespace"

    without_template_annotations do
      render_inline(TrailingWhitespaceComponent.new)
    end

    refute @rendered_content =~ /\s+\z/, "Rendered component contains trailing whitespace"
  end

  def test_renders_objects_in_component_view_context
    not_a_component = RendersNonComponent::NotAComponent.new
    component = RendersNonComponent.new(not_a_component: not_a_component)

    render_inline(component)

    assert_selector "span", text: "I'm not a component"

    assert(
      not_a_component.render_in_view_context == component,
      "Component-like object was not rendered in the parent component's view context"
    )
  end

  def test_renders_nested_collection
    items = %w[foo bar baz boo]
    render_inline(NestedCollectionWrapperComponent.new(items: items))

    index = 0

    assert_selector(".nested", count: 4) do |node|
      assert "#{items[index]}, Hello helper method" == node.text
      index += 1
    end
  end

  def test_concurrency_deadlock
    with_compiler_development_mode(true) do
      with_new_cache do
        mutex = Mutex.new

        t1 = Thread.new do
          mutex.synchronize do
            sleep 0.02
            render_inline(ContentEvalComponent.new)
          end
        end

        t = Thread.new do
          render_inline(ContentEvalComponent.new) do
            mutex.synchronize do
              sleep 0.01
            end
          end
        end

        t1.join
        t.join
      end
    end
  end

  def test_content_predicate_false
    render_inline(ContentPredicateComponent.new)

    assert_text("Default")
  end

  def test_content_predicate_true
    render_inline(ContentPredicateComponent.new.with_content("foo".html_safe))

    assert_text("foo")
  end

  def test_content_security_policy_nonce
    render_inline(ContentSecurityPolicyNonceComponent.new)

    assert_selector("script", text: "\n//<![CDATA[\n  \"alert('hello')\"\n\n//]]>\n", visible: :hidden)
  end

  def test_content_security_policy_nonce_with_strict_helpers
    with_helpers_enabled_config(false) do
      render_inline(ContentSecurityPolicyNonceComponent.new)

      assert_selector("script", text: "\n//<![CDATA[\n  \"alert('hello')\"\n\n//]]>\n", visible: :hidden)
    end
  end

  def test_use_helper
    render_inline(UseHelpersComponent.new)
    assert_selector ".helper__message", text: "Hello helper method"
  end

  def test_inline_component_renders_without_trailing_whitespace
    without_template_annotations do
      render_inline(InlineTrailingWhitespaceComponent.new)
    end

    refute @rendered_content =~ /\s+\z/, "Rendered component contains trailing whitespace"
  end

  def test_use_helpers_macros
    render_inline(UseHelpersMacroComponent.new)

    assert_selector ".helper__message", text: "Hello helper method"
  end

  def test_use_helpers_macros_with_args
    render_inline(UseHelpersMacroComponent.new)

    assert_selector ".helper__args-message", text: "Hello macro helper method"
  end

  def test_use_helpers_macros_with_kwargs
    render_inline(UseHelpersMacroComponent.new)

    assert_selector ".helper__kwargs-message", text: "Hello macro kwargs helper method"
  end

  def test_use_helpers_with_block
    render_inline(UseHelpersMacroComponent.new)

    assert_selector ".helper__block-message", text: "Hello block helper method"
  end

  def test_use_helper_macros
    render_inline(UseHelperMacroComponent.new)

    assert_selector ".helper__message", text: "Hello helper method"
  end

  def test_use_helper_macros_with_args
    render_inline(UseHelperMacroComponent.new)

    assert_selector ".helper__args-message", text: "Hello macro helper method"
  end

  def test_use_helper_macros_with_kwargs
    render_inline(UseHelperMacroComponent.new)

    assert_selector ".helper__kwargs-message", text: "Hello macro kwargs helper method"
  end

  def test_use_helper_macros_with_block
    render_inline(UseHelperMacroComponent.new)

    assert_selector ".helper__block-message", text: "Hello block helper method"
  end

  def test_use_helper_macros_with_prefix
    render_inline(UseHelperMacroComponent.new)

    assert_selector ".helper__prefix-message", text: "Hello macro prefix helper method"
  end

  def test_use_helper_macros_with_named_prefix
    render_inline(UseHelperMacroComponent.new)

    assert_selector ".helper__prefix-message", text: "Hello macro named prefix helper method"
  end

  def test_use_helpers_macros_with_prefix
    render_inline(UseHelpersMacroComponent.new)

    assert_selector ".helper__prefix-message", text: "Hello macro prefix helper method"
  end

  def test_use_helpers_macros_with_named_prefix
    render_inline(UseHelpersMacroComponent.new)

    assert_selector ".helper__named-prefix-message", text: "Hello macro named prefix helper method"
  end

  def test_with_format
    with_format(:json) do
      render_inline(MultipleFormatsComponent.new)

      assert_equal(rendered_json["hello"], "world")
    end
  end

  def test_strict_helpers
    with_helpers_enabled_config(false) do
      assert_raises ViewComponent::StrictHelperError do
        render_inline(HelpersProxyComponent.new)
      end
    end
  end
end
