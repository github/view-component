# frozen_string_literal: true

require "test_helper"
require "generators/view_component/rspec/rspec_generator"

Rails.application.load_generators

class RSpecGeneratorTest < Rails::Generators::TestCase
  tests ViewComponent::Generators::RspecGenerator
  destination Dir.mktmpdir
  setup :prepare_destination

  def test_generates_component
    run_generator %w[Dummy data]

    assert_file "spec/components/dummy_component_spec.rb" do |content|
      assert_match(
        "RSpec.describe DummyComponent, type: :component do", content
      )
    end
  end

  def test_generates_component_with_unchanged_component_path_with_config_flag
    with_generate_option(:use_component_path_for_rspec_tests, true) do
      run_generator %w[Dummy data]

      assert_file "spec/components/dummy_component_spec.rb" do |content|
        assert_match(
          "RSpec.describe DummyComponent, type: :component do", content
        )
      end
    end
  end

  def test_generates_component_with_different_component_path_with_config_flag
    with_generate_option(:use_component_path_for_rspec_tests, true) do
      with_custom_component_path("app/views/components") do
        run_generator %w[Dummy data]

        assert_file "spec/views/components/dummy_component_spec.rb" do |content|
          assert_match(
            "RSpec.describe DummyComponent, type: :component do", content
          )
        end
      end
    end
  end

  def test_generates_component_with_different_component_path_without_config_flag
    with_custom_component_path("app/views/components") do
      run_generator %w[Dummy data]

      assert_file "spec/components/dummy_component_spec.rb" do |content|
        assert_match(
          "RSpec.describe DummyComponent, type: :component do", content
        )
      end
    end
  end

  def test_generates_component_with_non_app_component_path
    with_generate_option(:use_component_path_for_rspec_tests, true) do
      with_config_option(:view_component_path, "lib/views/components") do
        run_generator %w[Dummy data]

        assert_file "spec/components/dummy_component_spec.rb" do |content|
          assert_match(
            "RSpec.describe DummyComponent, type: :component do", content
          )
        end
      end
    end
  end
end
