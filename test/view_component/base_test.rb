# frozen_string_literal: true

require "test_helper"

class ViewComponent::Base::UnitTest < Minitest::Test
  def test_templates_parses_all_types_of_paths
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
    compiler.stub(:matching_views_in_source_location, file_path) do
      templates = compiler.send(:templates)

      templates.each_with_index do |template, index|
        assert_equal(template[:path], file_path[index])
        assert_equal(template[:variant], expected[index][:variant])
        assert_equal(template[:handler], expected[index][:handler])
      end
    end
  end

  def test_calling_helpers_outside_render_raises
    component = ViewComponent::Base.new
    err = assert_raises ViewComponent::Base::ViewContextCalledBeforeRenderError do
      component.helpers
    end
    assert_equal "`helpers` can only be called at render time.", err.message
  end

  def test_calling_controller_outside_render_raises
    component = ViewComponent::Base.new
    err = assert_raises ViewComponent::Base::ViewContextCalledBeforeRenderError do
      component.controller
    end
    assert_equal "`controller` can only be called at render time.", err.message
  end
end
