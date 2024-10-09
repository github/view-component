# frozen_string_literal: true

require_relative "../../test_helper"
require "generators/view_component/component/component_generator"

class ComponentGeneratorTest < Rails::Generators::TestCase
  tests ViewComponent::Generators::ComponentGenerator
  destination Dir.mktmpdir
  setup :prepare_destination

  def test_component
    run_generator %w[example]

    assert_file "app/components/test_engine/example_component.rb" do |component|
      assert_match(/module TestEngine/, component)
      assert_match(/class ExampleComponent < ViewComponent::Base/, component)
      assert_no_match(/def initialize/, component)
    end
  end
end
