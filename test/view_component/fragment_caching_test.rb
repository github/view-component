# frozen_string_literal: true

require "test_helper"
require "support/fragment_caching_helper"

if Rails.version.to_f >= 6.0
  class DependencyTrackingTest < ActiveSupport::TestCase
    include FragmentCachingHelper

    def setup
      fragment_caching_setup
    end

    def teardown
      fragment_caching_teardown
    end

    test "finds dependencies of rails templates including components" do
      name = "integration_examples/partial"
      template = find_template name, template_finder

      dependencies = ActionView::DependencyTracker.find_dependencies name, template

      assert_equal ["integration_examples/test_partial", "PartialComponent"], dependencies
    end

    test "finds dependencies of components including template files and parent classes" do
      name = "InheritedWithOwnTemplateComponent"
      template = find_template name.underscore, component_finder

      dependencies = ActionView::DependencyTracker.find_dependencies name, template

      assert_equal ["inherited_with_own_template_component", "MyComponent"], dependencies
    end
  end

  class DigestorTest < ActiveSupport::TestCase
    include FragmentCachingHelper

    def setup
      fragment_caching_setup
    end

    def teardown
      fragment_caching_teardown
    end

    test "changes in component class are reflected in rendering view's digest" do
      name = "integration_examples/partial"
      finder = template_finder
      template = find_template name, finder

      first_digest = digest name, template, finder

      clear_digest_cache! finder

      second_digest = modify_file("app/components/partial_component.rb", "# Modified!") do
        digest name, template, finder
      end

      assert_not_equal first_digest, second_digest
    end

    test "changes in a component's parent class are reflected in the component's digest" do
      name = "ChildComponent"
      finder = component_finder
      template = find_template name.underscore, finder

      first_digest = digest name, template, finder

      clear_digest_cache! finder

      second_digest = modify_file("app/components/parent_component.rb", "# Modified!") do
        digest name, template, finder
      end

      assert_not_equal first_digest, second_digest
    end
  end
end
