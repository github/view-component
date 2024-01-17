# frozen_string_literal: true

require_relative "../../test_helper"
require "rails/generators/component/component_generator"

Dummy::Engine.load_generators

class ComponentGeneratorTest < Rails::Generators::TestCase
  tests Rails::Generators::ComponentGenerator
  # destination Dummy::Engine.root

  destination Dir.mktmpdir
  setup :prepare_destination

  arguments %w[user]

  def test_component
    run_generator

    assert_file "app/components/user_component.rb" do |component|
      assert_match(/module Dummy/, component)
      assert_match(/class UserComponent < ViewComponent::Base/, component)
      assert_no_match(/def initialize/, component)
    end
  end
end