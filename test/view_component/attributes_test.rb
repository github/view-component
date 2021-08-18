# frozen_string_literal: true

require "test_helper"
require "view_component/attributes"

class AttributesTest < ViewComponent::TestCase
  class MyAttributeComponent < ViewComponent::Base
    include ViewComponent::Attributes

    requires :title
    accepts :body
    accepts :posted_at, default: Date.today

    def call
      content_tag :div do
        safe_join([
          content_tag(:h1, @title),
          content_tag(:p, @body),
          content_tag(:date, @posted_at),
        ])
      end
    end
  end

  class MyInheritedAttributeComponent < MyAttributeComponent
  end

  def test_basic_attributes
    render_inline MyAttributeComponent.new(title: "foo")

    assert_selector("h1", text: "foo")
  end

  def test_exposes_attributes
    component = MyAttributeComponent.new(title: "foo", body: "hello world!")

    assert_equal "foo", component.title
    assert_equal "hello world!", component.body
  end

  def test_inherits_attributes
    new_component_class = Class.new(MyAttributeComponent) do
    end

    assert new_component_class.public_instance_methods.include?(:title)
  end

  def test_does_not_pollute_attribute_cache
    Class.new(ViewComponent::Base) do
      include ViewComponent::Attributes

      requires :fake_field
    end

    refute MyAttributeComponent.public_instance_methods.include?(:fake_field)
  end

  def test_all_attributes_provided
    posted_at = Date.yesterday
    render_inline MyAttributeComponent.new(title: "foo", body: "hello world!", posted_at: posted_at)

    assert_selector("h1", text: "foo")
    assert_selector("p", text: "hello world!")
    assert_selector("date", text: posted_at.to_s)
  end

  def test_required_attribute_raises_if_missing
    assert_raises ArgumentError do
      render_inline MyAttributeComponent.new
    end
  end

  def test_optional_arguments_default_to_nil
    component = MyAttributeComponent.new(title: "foo")
    assert_nil component.body
  end

  def test_default_values_are_set_if_argument_is_missing
    freeze_time do
      component = MyAttributeComponent.new(title: "foo")
      assert_equal Date.today, component.posted_at
    end
  end

  def test_explicit_nil_overrides_default_values
    component = MyAttributeComponent.new(title: "foo", posted_at: nil)
    assert_nil component.posted_at
  end

  def test_inheritance_works
    posted_at = Date.yesterday
    render_inline MyInheritedAttributeComponent.new(title: "foo", body: "hello world!", posted_at: posted_at)

    assert_selector("h1", text: "foo")
    assert_selector("p", text: "hello world!")
    assert_selector("date", text: posted_at.to_s)
  end
end
