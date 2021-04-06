# frozen_string_literal: true

require "test_helper"

class SlotableTest < ViewComponent::TestCase
  def test_renders_slots
    render_inline(SlotsComponent.new(class_names: "mt-4")) do |component|
      component.slot(:title) do
        "This is my title!"
      end
      component.slot(:subtitle) do
        "This is my subtitle!"
      end

      component.slot(:tab) do
        "Tab A"
      end
      component.slot(:tab) do
        "Tab B"
      end

      component.slot(:item) do
        "Item A"
      end
      component.slot(:item, highlighted: true) do
        "Item B"
      end
      component.slot(:item) do
        "Item C"
      end

      component.slot(:footer, class_names: "text-blue") do
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

  def test_inherited_component_renders_slots
    render_inline(SlotsInheritedComponent.new(class_names: "mt-4")) do |component|
      component.slot(:title) do
        "This is my title!"
      end
      component.slot(:subtitle) do
        "This is my subtitle!"
      end

      component.slot(:tab) do
        "Tab A"
      end
      component.slot(:tab) do
        "Tab B"
      end

      component.slot(:item) do
        "Item A"
      end
      component.slot(:item, highlighted: true) do
        "Item B"
      end
      component.slot(:item) do
        "Item C"
      end

      component.slot(:footer, class_names: "text-blue") do
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

  def test_invalid_slot_class_raises_error
    exception = assert_raises ArgumentError do
      render_inline(BadSlotComponent.new) do |component|
        component.slot(:title)
      end
    end

    assert_includes exception.message, "Title must inherit from ViewComponent::Slot"
  end

  def test_renders_slots_with_empty_collections
    render_inline(SlotsComponent.new) do |component|
      component.slot(:title) do
        "This is my title!"
      end

      component.slot(:subtitle) do
        "This is my subtitle!"
      end

      component.slot(:footer) do
        "This is the footer"
      end
    end

    assert_text "No tabs provided"
    assert_text "No items provided"
  end

  def test_renders_slots_template_raise_with_unknown_content_areas
    exception = assert_raises ArgumentError do
      render_inline(SlotsComponent.new) do |component|
        component.slot(:foo) { "Hello!" }
      end
    end

    assert_includes exception.message, "Unknown slot 'foo' - expected one of '[:title, :subtitle, :footer, :tab, :item]'"
  end

  def test_with_slot_raise_with_duplicate_slot_name
    exception = assert_raises ArgumentError do
      SlotsComponent.with_slot :title
    end

    assert_includes exception.message, "title slot declared multiple times"
  end

  def test_with_slot_raise_with_content_keyword
    exception = assert_raises ArgumentError do
      SlotsComponent.with_slot :content
    end

    assert_includes exception.message, ":content is a reserved slot name"
  end

  # In a previous implementation of slots,
  # the list of slots registered to a component
  # was accidentally assigned to all components!
  def test_slots_pollution
    new_component_class = Class.new(ViewComponent::Base)
    new_component_class.include(ViewComponent::Slotable)
    # this returned:
    # [SlotsComponent::Subtitle, SlotsComponent::Tab...]
    assert_empty new_component_class.slots
  end
end
