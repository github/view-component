# frozen_string_literal: true

require "test_helper"
require "generators/view_component/locale/locale_generator"

Rails.application.load_generators

class LocaleGeneratorTest < Rails::Generators::TestCase
  tests ViewComponent::Generators::LocaleGenerator
  destination Dir.mktmpdir
  setup :prepare_destination

  arguments %w[user]

  def test_component_generator
    run_generator

    I18n.available_locales.each do |locale|
      assert_file "app/components/user_component.yml" do |content|
        assert_match(/^#{locale}:\n/, content)
        assert_match(/^  hello: Hello\n/, content)
      end
    end
  end

  def test_component_generator_with_arguments
    run_generator %w[user name]

    I18n.available_locales.each do |locale|
      assert_file "app/components/user_component.yml" do |content|
        assert_match(/^#{locale}:\n/, content)
        assert_match(/^  name: Name\n/, content)
        assert_no_match(/^  hello: Hello\n/, content)
      end
    end
  end

  def test_component_generator_with_generate_distinct_locale_files
    with_generate_distinct_locale_files do
      run_generator
    end

    I18n.available_locales.each do |locale|
      assert_file "app/components/user_component.#{locale}.yml" do |content|
        assert_match(/^#{locale}:\n/, content)
        assert_match(/^  hello: Hello\n/, content)
      end
    end
  end

  def test_component_generator_with_sidecar
    run_generator %w[user --sidecar]

    I18n.available_locales.each do |locale|
      assert_file "app/components/user_component/user_component.yml" do |content|
        assert_match(/^#{locale}:\n/, content)
      end
    end
  end

  def test_component_generator_with_sidecar_with_generate_distinct_locale_files
    with_generate_distinct_locale_files do
      run_generator %w[user --sidecar]
    end

    I18n.available_locales.each do |locale|
      assert_file "app/components/user_component/user_component.#{locale}.yml" do |content|
        assert_match(/^#{locale}:\n/, content)
      end
    end
  end

  def test_component_with_namespace
    run_generator %w[admins/user]

    I18n.available_locales.each do |locale|
      assert_file "app/components/admins/user_component.yml" do |content|
        assert_match(/^#{locale}:\n/, content)
      end
    end
  end

  def test_component_with_namespace_with_generate_distinct_locale_files
    with_generate_distinct_locale_files do
      run_generator %w[admins/user]
    end

    I18n.available_locales.each do |locale|
      assert_file "app/components/admins/user_component.#{locale}.yml" do |content|
        assert_match(/^#{locale}:\n/, content)
      end
    end
  end

  def test_component_with_namespace_and_sidecar
    run_generator %w[admins/user --sidecar]

    I18n.available_locales.each do |locale|
      assert_file "app/components/admins/user_component/user_component.yml" do |content|
        assert_match(/^#{locale}:\n/, content)
      end
    end
  end

  def test_component_with_namespace_and_sidecar_with_generate_distinct_locale_files
    with_generate_distinct_locale_files do
      run_generator %w[admins/user --sidecar]
    end

    I18n.available_locales.each do |locale|
      assert_file "app/components/admins/user_component/user_component.#{locale}.yml" do |content|
        assert_match(/^#{locale}:\n/, content)
      end
    end
  end

  def test_component_with_generate_sidecar
    with_generate_sidecar(true) do
      with_generate_distinct_locale_files do
        run_generator %w[user]
      end

      I18n.available_locales.each do |locale|
        assert_file "app/components/user_component/user_component.#{locale}.yml" do |content|
          assert_match(/^#{locale}:\n/, content)
        end
      end
    end
  end

  private

  def with_generate_distinct_locale_files(&block)
    with_generate_option(:distinct_locale_files, true, &block)
  end
end
