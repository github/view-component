# frozen_string_literal: true

require "test_helper"

class ViewComponentTest < ViewComponent::TestCase
  def test_render_inline
    render_inline(MyComponent.new)

    assert_selector("div", text: "hello,world!")
  end

  def test_render_inline_returns_nokogiri_fragment
    assert_includes render_inline(MyComponent.new).css("div").to_html, "hello,world!"
  end

  def test_render_inline_sets_rendered_component
    render_inline(MyComponent.new)

    assert_includes rendered_component, "hello,world!"
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

  def test_render_without_template
    render_inline(InlineComponent.new)

    assert_predicate InlineComponent, :compiled?
    assert_selector("input[type='text'][name='name']")
  end

  def test_render_without_template_variant
    render_inline(InlineComponent.new.with_variant(:email))

    assert_predicate InlineComponent, :compiled?
    assert_selector("input[type='text'][name='email']")
  end

  def test_render_child_without_template
    render_inline(InlineChildComponent.new)

    assert_predicate InlineChildComponent, :compiled?
    assert_selector("input[type='text'][name='name']")
  end

  def test_renders_slim_template
    render_inline(SlimComponent.new(message: "bar")) { "foo" }

    assert_text("foo")
    assert_text("bar")
  end

  def test_renders_slim_with_many_slots
    render_inline(SlimRendersManyComponent.new) do |c|
      c.slim_component(message: "Bar A") do
        "Foo A "
      end
      c.slim_component(message: "Bar B") do
        "Foo B "
      end
    end

    assert_selector(".slim-div", text: "Foo A Bar A")
    assert_selector(".slim-div", text: "Foo B Bar B")
  end

  def test_renders_slim_with_html_formatted_slot
    render_inline(SlimHTMLFormattedSlotComponent.new)

    assert_selector("p", text: "HTML Formatted")
  end

  def test_renders_slim_escaping_dangerous_html_assign
    render_inline(SlimWithUnsafeHTMLComponent.new)

    refute_selector("script")
    assert_selector(".slim-div", text: "<script>alert('xss')</script>")
  end

  def test_renders_haml_template
    render_inline(HamlComponent.new(message: "bar")) { "foo" }

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

  def test_renders_component_with_variant
    with_variant :phone do
      render_inline(VariantsComponent.new)

      assert_text("Phone")
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

  def test_renders_content_areas_template_with_initialize_arguments
    render_inline(ContentAreasComponent.new(title: "Hi!", footer: "Bye!")) do |component|
      component.with(:body) { "Have a nice day." }
    end
  end

  def test_renders_content_areas_template_with_content
    render_inline(ContentAreasComponent.new(footer: "Bye!")) do |component|
      component.with(:title, "Hello!")
      component.with(:body) { "Have a nice day." }
    end

    assert_selector(".title", text: "Hello!")
    assert_selector(".body", text: "Have a nice day.")
    assert_selector(".footer", text: "Bye!")
  end

  def test_renders_content_areas_template_with_block
    render_inline(ContentAreasComponent.new(footer: "Bye!")) do |component|
      component.with(:title) { "Hello!" }
      component.with(:body) { "Have a nice day." }
    end

    assert_selector(".title", text: "Hello!")
    assert_selector(".body", text: "Have a nice day.")
    assert_selector(".footer", text: "Bye!")
  end

  def test_renders_content_areas_template_replaces_content
    render_inline(ContentAreasComponent.new(footer: "Bye!")) do |component|
      component.with(:title) { "Hello!" }
      component.with(:title, "Hi!")
      component.with(:body) { "Have a nice day." }
    end

    assert_selector(".title", text: "Hi!")
    assert_selector(".body", text: "Have a nice day.")
    assert_selector(".footer", text: "Bye!")
  end

  def test_renders_content_areas_template_can_wrap_render_arguments
    render_inline(ContentAreasComponent.new(title: "Hello!", footer: "Bye!")) do |component|
      component.with(:title) { "<strong>#{component.title}</strong>".html_safe }
      component.with(:body) { "Have a nice day." }
    end

    assert_selector(".title strong", text: "Hello!")
    assert_selector(".body", text: "Have a nice day.")
    assert_selector(".footer", text: "Bye!")
  end

  def test_renders_content_areas_template_raise_with_unknown_content_areas
    exception = assert_raises ArgumentError do
      render_inline(ContentAreasComponent.new(footer: "Bye!")) do |component|
        component.with(:foo) { "Hello!" }
      end
    end

    assert_includes exception.message, "Unknown content_area 'foo' - expected one of '[:title, :body, :footer]'"
  end

  def test_with_content_areas_raise_with_content_keyword
    exception = assert_raises ArgumentError do
      ContentAreasComponent.with_content_areas :content
    end

    assert_includes exception.message, ":content is a reserved content area name"
  end

  def test_renders_helper_method_through_proxy
    render_inline(HelpersProxyComponent.new)

    assert_text("Hello helper method")
  end

  def test_renders_helper_method_within_nested_component
    render_inline(HelpersContainerComponent.new)

    assert_text("Hello helper method")
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
    render_inline(AssetComponent.new)

    assert_text(%r{http://assets.example.com/assets/application-\w+.css})
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
      ::ViewComponent::VERSION::PATCH
    ].join(".")
    assert_equal version_string, ::ViewComponent::VERSION::STRING
  end

  def test_renders_component_with_translations
    render_inline(TranslationsComponent.new)

    assert_selector("h1", text: I18n.t("translations_component.title"))
    assert_selector("h2", text: I18n.t("translations_component.subtitle"))
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

    assert_text("Content")
  end

  def test_render_check
    render_inline(RenderCheckComponent.new)

    assert_text("Rendered")

    controller.view_context.cookies[:shown] = true

    render_inline(RenderCheckComponent.new)

    assert_no_text("Rendered")
    refute_component_rendered
  end

  def test_assert_select
    render_inline(MyComponent.new)

    assert_selector("div")
  end

  def test_validations_component
    exception = assert_raises ActiveModel::ValidationError do
      render_inline(ValidationsComponent.new)
    end

    assert_equal exception.message, "Validation failed: Content can't be blank"
  end

  # TODO: Remove in v3.0.0
  def test_before_render_check
    exception = assert_raises ActiveModel::ValidationError do
      render_inline(OldValidationsComponent.new)
    end

    assert_equal exception.message, "Validation failed: Content can't be blank"
  end

  def test_compiles_unrendered_component
    assert UnreferencedComponent.compiled?
  end

  def test_compiles_components_without_initializers
    assert MissingInitializerComponent.compiled?
  end

  def test_renders_when_initializer_is_not_defined
    render_inline(MissingInitializerComponent.new)

    assert_selector("div", text: "Hello, world!")
  end

  def test_raises_error_when_sidecar_template_is_missing
    exception = assert_raises ViewComponent::TemplateError do
      render_inline(MissingTemplateComponent.new)
    end

    assert_includes exception.message, "Could not find a template file or inline render method for MissingTemplateComponent"
  end

  def test_raises_error_when_more_than_one_sidecar_template_is_present
    error = assert_raises ViewComponent::TemplateError do
      render_inline(TooManySidecarFilesComponent.new)
    end

    assert_includes error.message, "More than one template found for TooManySidecarFilesComponent."
  end

  def test_raises_error_when_more_than_one_sidecar_template_for_a_variant_is_present
    error = assert_raises ViewComponent::TemplateError do
      render_inline(TooManySidecarFilesForVariantComponent.new)
    end

    assert_includes error.message, "More than one template found for variants 'test' and 'testing' in TooManySidecarFilesForVariantComponent"
  end

  def test_raise_error_when_default_template_file_and_inline_default_call_exist
    error = assert_raises ViewComponent::TemplateError do
      render_inline(DefaultTemplateAndInlineDefaultTemplateComponent.new)
    end

    assert_includes error.message, "Template file and inline render method found for DefaultTemplateAndInlineDefaultTemplateComponent."
  end

  def test_raise_error_when_variant_template_file_and_inline_variant_call_exist
    error = assert_raises ViewComponent::TemplateError do
      with_variant :phone do
        render_inline(VariantTemplateAndInlineVariantTemplateComponent.new)
      end
    end

    assert_includes error.message, "Template file and inline render method found for variant 'phone' in VariantTemplateAndInlineVariantTemplateComponent."
  end

  def test_raise_error_when_template_file_and_sidecar_directory_template_exist
    error = assert_raises ViewComponent::TemplateError do
      render_inline(TemplateAndSidecarDirectoryTemplateComponent.new)
    end

    assert_includes error.message, "More than one template found for TemplateAndSidecarDirectoryTemplateComponent."
  end

  def test_backtrace_returns_correct_file_and_line_number
    error = assert_raises NameError do
      render_inline(ExceptionInTemplateComponent.new)
    end

    assert_match %r[app/components/exception_in_template_component\.html\.erb:2], error.backtrace[0]
  end

  def test_render_collection
    products = [OpenStruct.new(name: "Radio clock"), OpenStruct.new(name: "Mints")]
    render_inline(ProductComponent.with_collection(products, notice: "On sale"))

    assert_selector("h1", text: "Product", count: 2)
    assert_selector("h2", text: "Radio clock")
    assert_selector("h2", text: "Mints")
    assert_selector("p", text: "On sale", count: 2)
    assert_selector("p", text: "Radio clock counter: 1")
    assert_selector("p", text: "Mints counter: 2")
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

    assert_selector("figure[data-index=0]", { count: 1 })
    assert_selector("figcaption", text: "Photo.1 - Yellow flowers")

    assert_selector("figure[data-index=1]", { count: 1 })
    assert_selector("figcaption", text: "Photo.2 - Mountains at sunset")
  end

  def test_render_collection_nil_and_empty_collection
    [nil, []].each do |collection|
      render_inline(ProductComponent.with_collection(collection, notice: "On sale"))

      assert_no_text("Products")
    end
  end

  def test_render_collection_missing_collection_object
    exception = assert_raises ArgumentError do
      render_inline(ProductComponent.with_collection("foo"))
    end

    assert_equal exception.message, "The value of the argument isn't a valid collection. Make sure it responds to to_ary: \"foo\""
  end

  def test_render_collection_missing_arg
    products = [OpenStruct.new(name: "Radio clock"), OpenStruct.new(name: "Mints")]
    exception = assert_raises ArgumentError do
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
    exception = assert_raises ArgumentError do
      render_inline(MissingCollectionParameterNameComponent.with_collection([]))
    end

    assert_match(/MissingCollectionParameterNameComponent initializer must accept `foo` collection parameter/, exception.message)
  end

  def test_collection_component_missing_default_parameter_name
    exception = assert_raises ArgumentError do
      render_inline(
        MissingDefaultCollectionParameterComponent.with_collection([OpenStruct.new(name: "Mints")])
      )
    end

    assert_match(/MissingDefaultCollectionParameterComponent initializer must accept `missing_default_collection_parameter` collection parameter/, exception.message)
  end

  def test_component_with_invalid_parameter_names
    begin
      old_cache = ViewComponent::CompileCache.cache
      ViewComponent::CompileCache.cache = Set.new

      exception = assert_raises ArgumentError do
        InvalidParametersComponent.compile(raise_errors: true)
      end

      assert_match(/InvalidParametersComponent initializer cannot contain `content` since it will override a public ViewComponent method/, exception.message)
    ensure
      ViewComponent::CompileCache.cache = old_cache
    end
  end

  def test_component_with_invalid_named_parameter_names
    begin
      old_cache = ViewComponent::CompileCache.cache
      ViewComponent::CompileCache.cache = Set.new

      exception = assert_raises ArgumentError do
        InvalidNamedParametersComponent.compile(raise_errors: true)
      end

      assert_match(/InvalidNamedParametersComponent initializer cannot contain `content` since it will override a public ViewComponent method/, exception.message)
    ensure
      ViewComponent::CompileCache.cache = old_cache
    end
  end

  def test_collection_component_with_trailing_comma_attr_reader
    exception = assert_raises ArgumentError do
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

  def test_inherited_component_inherits_template
    render_inline(InheritedTemplateComponent.new)

    assert_selector("div", text: "hello,world!")
  end

  def test_inherited_component_overrides_inherits_template
    render_inline(InheritedWithOwnTemplateComponent.new)

    assert_selector("div", text: "hello, my own template")
  end

  def test_inherited_inline_component_inherits_inline_method
    render_inline(InheritedInlineComponent.new)

    assert_predicate InheritedInlineComponent, :compiled?
    assert_selector("input[type='text'][name='name']")
  end
end
