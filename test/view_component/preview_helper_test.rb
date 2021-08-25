# frozen_string_literal: true

require "test_helper"
include PreviewHelper

class PreviewHelperTest < ActiveSupport::TestCase
  def test_returns_the_language_from_the_file_extention
    template = Minitest::Mock.new
    template.expect :identifier, "template.html.erb"

    assert_equal(PreviewHelper.prism_language_name(template: template), "erb")
    template.verify
  end

  def test_returns_fallback_language_if_file_extention_unknown
    template = Minitest::Mock.new
    template.expect :identifier, "template.html.slim"

    assert_equal(PreviewHelper.prism_language_name(template: template), "ruby")
    template.verify
  end

  def test_returns_language_using_a_template_path
    template_path = "test.html.erb"
    assert_equal(PreviewHelper.prism_language_name(template: template_path), "erb")
  end

  def test_returns_language_using_a_template_path_with_haml
    template_path = "test.haml.html"
    assert_equal(PreviewHelper.prism_language_name(template: template_path), "haml")
  end

  def test_returns_language_using_a_template_with_fallback
    template_path = "test.slim.html"
    assert_equal(PreviewHelper.prism_language_name(template: template_path), "ruby")
  end

  def test_returns_the_template_source
    template_identifier = "preview/no_template"

    expected_template_source = "expected_template"
    mock_template = Minitest::Mock.new
    mock_template.expect(:source, expected_template_source)
    mock_template.expect(:source, expected_template_source)

    lookup_context = Minitest::Mock.new
    lookup_context.expect(:find_template, mock_template, [template_identifier])

    template = PreviewHelper.find_template_source(
      lookup_context: lookup_context,
      template_identifier: template_identifier
    )
    assert_equal(template.source, "expected_template")
  end

  if Rails.version.to_f < 6.1
    def test_returns_the_template_source_with_template
      template_identifier = "preview/template"
      expected_source = "<%= PreviewTest %>"

      mock_template = Minitest::Mock.new
      mock_template.expect(:source, "")
      mock_template.expect(:source, "")

      lookup_context = Minitest::Mock.new
      lookup_context.expect(:find_template, mock_template, [template_identifier])

      mock = Minitest::Mock.new
      mock.expect :map, [template_identifier + ".html.haml"]
      ViewComponent::Base.stub :preview_paths, mock do
        File.stub(:read, expected_source) do
          template = PreviewHelper.find_template_source(
            lookup_context: lookup_context,
            template_identifier: template_identifier
          )
          assert_equal(template, expected_source)
        end
      end
    end

    def test_returns_the_template_source_with_template_but_no_matching_template_found
      template_identifier = "preview/template"

      mock_template = Minitest::Mock.new
      mock_template.expect(:source, "")
      mock_template.expect(:source, "")

      lookup_context = Minitest::Mock.new
      lookup_context.expect(:find_template, mock_template, [template_identifier])

      mock = Minitest::Mock.new
      mock.expect :map, []
      ViewComponent::Base.stub :preview_paths, mock do
        exception = assert_raises RuntimeError do
          PreviewHelper.find_template_source(lookup_context: lookup_context, template_identifier: template_identifier)
        end

        assert_equal("found 0 matches for templates for #{template_identifier}.", exception.message)
      end
    end

    def test_returns_the_template_source_with_template_but_there_is_a_conflict
      template_identifier = "preview/template"

      mock_template = Minitest::Mock.new
      mock_template.expect(:source, "")
      mock_template.expect(:source, "")

      lookup_context = Minitest::Mock.new
      lookup_context.expect(:find_template, mock_template, [template_identifier])

      mock = Minitest::Mock.new
      mock.expect :map, [template_identifier + ".html.haml", template_identifier + ".html.erb"]
      ViewComponent::Base.stub :preview_paths, mock do
        exception = assert_raises RuntimeError do
          PreviewHelper.find_template_source(lookup_context: lookup_context, template_identifier: template_identifier)
        end
        assert_equal("found multiple templates for #{template_identifier}.", exception.message)
      end
    end
  end
end
