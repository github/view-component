# frozen_string_literal: true

require "test_helper"

class SlotsV2sTest < ViewComponent::TestCase
  def test_renders_slots
    render_inline(SlotsV2Component.new(classes: "mt-4")) do |component|
      component.title do
        "This is my title!"
      end
      component.subtitle do
        "This is my subtitle!"
      end

      component.tab do
        "Tab A"
      end
      component.tab do
        "Tab B"
      end

      component.item do
        "Item A"
      end
      component.item(highlighted: true) do
        "Item B"
      end
      component.item do
        "Item C"
      end

      component.footer(classes: "text-blue") do
        "This is the footer"
      end
    end

    assert_selector(".card.mt-4")

    assert_selector(".title", text: "This is my title!")

    assert_selector(".subtitle", text: "This is my subtitle!")

    assert_selector(".tab", text: "Tab A")
    assert_selector(".tab", text: "Tab B")

    assert_selector(".item", count: 3)
    assert_selector(".item.highlighted", count: 1)
    assert_selector(".item.normal", count: 2)

    assert_selector(".footer.text-blue")
  end

  def test_renders_slots_in_inherited_components
    render_inline(InheritedSlotsV2Component.new(classes: "mt-4")) do |component|
      component.title do
        "This is my title!"
      end
      component.subtitle do
        "This is my subtitle!"
      end

      component.tab do
        "Tab A"
      end
      component.tab do
        "Tab B"
      end

      component.item do
        "Item A"
      end
      component.item(highlighted: true) do
        "Item B"
      end
      component.item do
        "Item C"
      end

      component.footer(classes: "text-blue") do
        "This is the footer"
      end
    end

    assert_selector(".card.mt-4")

    assert_selector(".title", text: "This is my title!")

    assert_selector(".subtitle", text: "This is my subtitle!")

    assert_selector(".tab", text: "Tab A")
    assert_selector(".tab", text: "Tab B")

    assert_selector(".item", count: 3)
    assert_selector(".item.highlighted", count: 1)
    assert_selector(".item.normal", count: 2)

    assert_selector(".footer.text-blue", text: "This is the footer")
  end

  def test_renders_slots_with_empty_collections
    render_inline(SlotsV2Component.new) do |component|
      component.title do
        "This is my title!"
      end

      component.subtitle do
        "This is my subtitle!"
      end

      component.footer do
        "This is the footer"
      end
    end

    assert_text "No tabs provided"
    assert_text "No items provided"
  end

  def test_renders_slots_template_raise_with_unknown_content_areas
    assert_raises NoMethodError do
      render_inline(SlotsV2Component.new) do |component|
        component.foo { "Hello!" }
      end
    end
  end

  def test_sub_component_raise_with_duplicate_slot_name
    exception = assert_raises ArgumentError do
      SlotsV2Component.renders_one :title
    end

    assert_includes exception.message, "title slot declared multiple times"
  end

  def test_sub_component_with_positional_args
    render_inline(SlotsV2WithPosArgComponent.new(classes: "mt-4")) do |component|
      component.item("my item", classes: "hello") { "My rad item" }
    end

    assert_selector(".item", text: "my item")
    assert_selector(".item-content", text: "My rad item")
  end

  def test_sub_component_template_rendering
    render_inline(Nested::SlotsV2Component.new) do |component|
      component.item do |sub_component|
        sub_component.thing do
          "My rad thing"
        end
      end
    end

    assert_selector(".thing", text: "My rad thing")
  end

  def test_slot_with_component_delegate
    render_inline SlotsV2DelegateComponent.new do |component|
      component.item do
        "Item A"
      end
      component.item(highlighted: true) do
        "Item B"
      end
      component.item do
        "Item C"
      end
    end

    assert_selector(".item", count: 3)
    assert_selector(".item.highlighted", count: 1)
    assert_selector(".item.normal", count: 2)
  end

  def test_slot_with_respond_to
    component = SlotsV2DelegateComponent.new

    render_inline component do |c|
      c.item do
        "Item A"
      end
    end

    assert component.items.first.respond_to?(:classes)
  end

  def test_slot_with_collection
    render_inline SlotsV2DelegateComponent.new do |component|
      component.items([{ highlighted: false }, { highlighted: true }, { highlighted: false }]) do
        "My Item"
      end
    end

    assert_selector(".item", count: 3, text: "My Item")
    assert_selector(".item.highlighted", count: 1)
    assert_selector(".item.normal", count: 2)
  end

  def test_renders_nested_content_in_order
    render_inline TitleWrapperComponent.new(title: "Hello world!")

    assert_selector("h1", text: /Hello world/)
    assert_text(/Hello world/, count: 1)
  end

  # In a previous implementation of slots,
  # the list of slots registered to a component
  # was accidentally assigned to all components!
  def test_sub_components_pollution
    new_component_class = Class.new(ViewComponent::Base)
    # this returned:
    # [SlotsV2Component::Subtitle, SlotsV2Component::Tab...]
    assert_empty new_component_class.registered_slots
  end

  def test_renders_slots_with_before_render_hook
    render_inline(SlotsV2BeforeRenderComponent.new) do |component|
      component.title do
        "This is my title!"
      end

      component.greeting do
        "John Doe"
      end
      component.greeting do
        "Jane Doe"
      end
    end

    assert_selector("h1", text: "Testing - This is my title!")
    assert_selector(".greeting", text: "Hello, John Doe")
    assert_selector(".greeting", text: "Hello, Jane Doe")
  end

  def test_slots_accessible_in_render_predicate
    render_inline(SlotsV2RenderPredicateComponent.new) do |component|
      component.title do
        "This is my title!"
      end
    end

    assert_selector("h1", text: "This is my title!")
  end

  def test_slots_without_render_block
    render_inline(SlotsV2WithoutContentBlockComponent.new) do |component|
      component.title(title: "This is my title!")
    end

    assert_selector("h1", text: "This is my title!")
  end

  def test_slot_with_block_content
    render_inline(SlotsV2BlockComponent.new)

    assert_selector("p", text: "Footer part 1")
    assert_selector("p", text: "Footer part 2")
  end

  def test_lambda_slot_with_missing_block
    render_inline(SlotsV2Component.new(classes: "mt-4")) do |component|
      component.footer(classes: "text-blue")
    end
  end

  def test_slot_with_nested_blocks_content_selectable_true
    render_inline(NestedSharedState::TableComponent.new(selectable: true)) do |table_card|
      table_card.header("regular_argument", class_names: "table__header extracted_kwarg", data: { splatted_kwarg: "splatted_keyword_argument"}) do |header|
        header.cell { "Cell1" }
        header.cell(class_names: "-has-sort") { "Cell2" }
      end
    end

    assert_selector("div.table div.table__header div.table__cell", text: "Cell1")
    assert_selector("div.table div.table__header div.table__cell.-has-sort", text: "Cell2")

    # Check shared data through Proc
    assert_selector("div.table div.table__header span", text: "Selectable")

    # Check regular arguments
    assert_selector('div.table div.table__header[data-argument="regular_argument"]')

    # Check extracted keyword argument
    assert_selector("div.table div.table__header.extracted_kwarg")

    # Check splatted keyword arguments
    assert_selector('div.table div.table__header[data-splatted-kwarg="splatted_keyword_argument"]')
  end

  def test_slot_with_nested_blocks_content_selectable_false
    render_inline(NestedSharedState::TableComponent.new(selectable: false)) do |table_card|
      table_card.header do |header|
        header.cell { "Cell1" }
        header.cell(class_names: "-has-sort") { "Cell2" }
      end
    end

    assert_selector("div.table div.table__header div.table__cell", text: "Cell1")
    assert_selector("div.table div.table__header div.table__cell.-has-sort", text: "Cell2")

    # Check shared data through Proc
    refute_selector("div.table div.table__header span", text: "Selectable")
  end
end
