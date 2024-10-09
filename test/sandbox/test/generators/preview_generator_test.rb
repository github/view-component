# frozen_string_literal: true

require "test_helper"
require "generators/view_component/preview/preview_generator"

# See: https://github.com/rails/rails/pull/47752#issuecomment-1720256371
require "active_record"

Rails.application.load_generators

class PreviewGeneratorTest < Rails::Generators::TestCase
  tests ViewComponent::Generators::PreviewGenerator
  destination Dir.mktmpdir
  setup :prepare_destination

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

  def test_component_preview_with_preview_path_option
    with_preview_paths([]) do
      run_generator %w[user --preview --preview-path other/test/components/previews]

      assert_file "other/test/components/previews/user_component_preview.rb" do |component|
        assert_no_match(/module/, component)
        assert_match(/class UserComponentPreview < /, component)
        assert_match(/render\(UserComponent.new\)/, component)
      end
    end
  end

  def test_component_preview_with_one_overridden_preview_path
    with_preview_paths(%w[spec/components/previews]) do
      run_generator %w[user --preview]

      assert_file "spec/components/previews/user_component_preview.rb" do |component|
        assert_no_match(/module/, component)
        assert_match(/class UserComponentPreview < /, component)
        assert_match(/render\(UserComponent.new\)/, component)
      end
    end
  end

  def test_component_preview_with_two_overridden_preview_paths
    with_preview_paths(%w[spec/components/previews some/other/directory]) do
      run_generator %w[user --preview]

      assert_no_file "test/components/previews/user_component_preview.rb"
      assert_no_file "spec/components/previews/user_component_preview.rb"
      assert_no_file "some/other/directory/user_component_preview.rb"
    end
  end

  def test_component_preview_with_two_overridden_preview_paths_and_preview_path_option
    with_preview_paths(%w[spec/components/previews some/other/directory]) do
      run_generator %w[user --preview --preview-path other/test/components/previews]

      assert_file "other/test/components/previews/user_component_preview.rb" do |component|
        assert_no_match(/module/, component)
        assert_match(/class UserComponentPreview < /, component)
        assert_match(/render\(UserComponent.new\)/, component)
      end
    end
  end

  def test_component_preview_with_namespace
    with_preview_paths([]) do
      run_generator %w[admins/user --preview]

      assert_file "test/components/previews/admins/user_component_preview.rb" do |component|
        assert_no_match(/module/, component)
        assert_match(/class Admins::UserComponentPreview < /, component)
        assert_match(/render\(Admins::UserComponent.new\)/, component)
      end
    end
  end

  def test_component_generator_with_attributes
    with_preview_paths([]) do
      run_generator %w[user nickname fullname]

      assert_file "test/components/previews/user_component_preview.rb" do |preview|
        assert_no_match(/module/, preview)
        assert_match(/class UserComponentPreview/, preview)
        assert_match(/render\(UserComponent.new\(nickname: "nickname", fullname: "fullname"\)\)/, preview)
      end
    end
  end

  def test_component_with_namespace_and_attributes
    with_preview_paths([]) do
      run_generator %w[admins/user nickname fullname]

      assert_file "test/components/previews/admins/user_component_preview.rb" do |preview|
        assert_no_match(/module/, preview)
        assert_match(/class Admins::UserComponentPreview/, preview)
        assert_match(/render\(Admins::UserComponent.new\(nickname: "nickname", fullname: "fullname"\)\)/, preview)
      end
    end
  end
end
