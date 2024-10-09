# frozen_string_literal: true

require "test_helper"
require "generators/view_component/component/component_generator"

Rails.application.load_generators

class ComponentGeneratorTest < Rails::Generators::TestCase
  tests ViewComponent::Generators::ComponentGenerator
  destination Dir.mktmpdir
  setup :prepare_destination

  arguments %w[user]

  def test_component
    run_generator

    assert_file "app/components/user_component.rb" do |component|
      assert_no_match(/module/, component)
      assert_match(/class UserComponent < ViewComponent::Base/, component)
      assert_no_match(/def initialize/, component)
    end
  end

  def test_component_tests
    run_generator %w[user --test-framework test_unit]

    assert_file "test/components/user_component_test.rb" do |component|
      assert_no_match(/module/, component)
      assert_match(/class UserComponentTest < /, component)
      assert_match(/def test_component_renders_something_useful/, component)
    end
  end

  def test_component_preview
    with_preview_paths([]) do
      run_generator %w[user --preview]

      assert_file "test/components/previews/user_component_preview.rb" do |component|
        assert_no_match(/module/, component)
        assert_match(/class UserComponentPreview < /, component)
        assert_match(/render\(UserComponent.new\)/, component)
      end
    end
  end

  def test_component_with_arguments
    run_generator %w[user name]

    assert_file "app/components/user_component.rb" do |component|
      assert_no_match(/module/, component)
      assert_match(/class UserComponent < /, component)
      assert_match(/def initialize\(name:\)/, component)
    end
  end

  def test_component_with_inline
    run_generator %w[user name --inline]

    assert_file "app/components/user_component.rb" do |component|
      assert_match(/def call/, component)
    end

    assert_no_file "app/components/user_component.html.erb"
    assert_no_file "component.html.erb"
  end

  def test_component_with_parent
    run_generator %w[user --parent MyOtherBaseComponent]

    assert_file "app/components/user_component.rb" do |component|
      assert_no_match(/module/, component)
      assert_match(/class UserComponent < MyOtherBaseComponent/, component)
    end
  end

  def test_component_with_parent_and_application_component_class
    with_application_component_class do
      run_generator %w[user --parent MyOtherBaseComponent]

      assert_file "app/components/user_component.rb" do |component|
        assert_no_match(/module/, component)
        assert_match(/class UserComponent < MyOtherBaseComponent/, component)
      end
    end
  end

  def test_component_with_parent_and_custom_component_parent_class
    with_custom_component_parent_class("MyBaseComponent") do
      run_generator %w[user --parent MyOtherBaseComponent]

      assert_file "app/components/user_component.rb" do |component|
        assert_no_match(/module/, component)
        assert_match(/class UserComponent < MyOtherBaseComponent/, component)
      end
    end
  end

  def test_component_with_namespace
    run_generator %w[admins/user]

    assert_file "app/components/admins/user_component.rb" do |component|
      assert_no_match(/module/, component)
      assert_match(/class Admins::UserComponent < /, component)
    end
  end

  def test_component_tests_with_namespace
    run_generator %w[admins/user --test-framework test_unit]

    assert_file "test/components/admins/user_component_test.rb" do |component|
      assert_no_match(/module/, component)
      assert_match(/class Admins::UserComponentTest < /, component)
      assert_match(/def test_component_renders_something_useful/, component)
    end
  end

  def test_invoking_erb_template_engine
    run_generator %w[user --template-engine erb]

    assert_file "app/components/user_component.html.erb"
  end

  def test_invoking_slim_template_engine
    run_generator %w[user --template-engine slim]

    assert_file "app/components/user_component.html.slim"
  end

  def test_invoking_haml_template_engine
    run_generator %w[user --template-engine haml]

    assert_file "app/components/user_component.html.haml"
  end

  def test_invoking_tailwindcss_template_engine
    run_generator %w[user --template-engine tailwindcss]

    assert_file "app/components/user_component.html.erb"
  end

  def test_generating_components_with_custom_component_path
    with_custom_component_path("app/parts") do
      run_generator %w[user]

      assert_file "app/parts/user_component.rb"
      assert_file "app/parts/user_component.html.erb"
    end
  end

  def test_generating_components_with_application_component_class
    with_application_component_class do
      run_generator %w[user]

      assert_file "app/components/user_component.rb" do |component|
        assert_no_match(/module/, component)
        assert_match(/class UserComponent < ApplicationComponent/, component)
      end
    end
  end

  def test_generating_components_with_custom_component_parent_class
    with_custom_component_parent_class("MyBaseComponent") do
      run_generator %w[user]

      assert_file "app/components/user_component.rb" do |component|
        assert_no_match(/module/, component)
        assert_match(/class UserComponent < MyBaseComponent/, component)
      end
    end
  end

  def test_generating_components_with_application_component_class_and_custom_parent_class
    with_application_component_class do
      with_custom_component_parent_class("MyBaseComponent") do
        run_generator %w[user]

        assert_file "app/components/user_component.rb" do |component|
          assert_no_match(/module/, component)
          assert_match(/class UserComponent < MyBaseComponent/, component)
        end
      end
    end
  end

  def test_component_with_stimulus
    run_generator %w[user --stimulus]

    assert_file "app/components/user_component.html.erb" do |component|
      assert_match(/data-controller="user-component"/, component)
    end

    assert_file "app/components/user_component_controller.js"
  end

  def test_component_with_stimulus_and_inline
    run_generator %w[user --stimulus --inline]

    assert_file "app/components/user_component.rb" do |component|
      assert_match(/data: { controller: "user-component" }/, component)
    end

    assert_file "app/components/user_component_controller.js"
  end

  def test_component_with_legacy_stimulus_and_sidecar
    with_package_json({dependencies: {stimulus: "0.0.0"}}) do
      run_generator %w[user --stimulus --sidecar]

      assert_file "app/components/user_component/user_component_controller.js" do |file|
        assert_match(/import { Controller } from "stimulus"/, file)
      end
    end
  end

  def test_component_with_stimulus_and_sidecar
    run_generator %w[user --stimulus --sidecar]

    assert_file "app/components/user_component/user_component_controller.js" do |file|
      assert_match(/import { Controller } from "@hotwired\/stimulus"/, file)
    end
  end

  def test_component_with_stimulus_and_sidecar_and_inline
    run_generator %w[user --stimulus --sidecar --inline]

    assert_file "app/components/user_component.rb" do |component|
      assert_match(/data: { controller: "user-component--user-component" }/, component)
    end

    assert_file "app/components/user_component/user_component_controller.js"
  end

  def test_component_with_locale
    run_generator %w[user --locale]

    assert_file "app/components/user_component.rb"
    assert_file "app/components/user_component.yml"
  end

  def test_component_with_locale_and_sidecar
    run_generator %w[user --locale --sidecar]

    assert_file "app/components/user_component.rb"
    assert_file "app/components/user_component/user_component.yml"
  end

  def test_component_with_generate_sidecar
    with_generate_sidecar(true) do
      run_generator %w[user]

      assert_file "app/components/user_component/user_component.html.erb"
    end
  end

  private

  def with_package_json(content, &block)
    package_json_pathname = Rails.root.join("package.json")
    package_json_pathname.write(JSON.generate(content))
    yield
  ensure
    package_json_pathname.delete
  end
end
