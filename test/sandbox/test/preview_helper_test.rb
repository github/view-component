# frozen_string_literal: true

require "test_helper"
# rubocop:disable Style/MixinUsage
include PreviewHelper
# rubocop:enable Style/MixinUsage
class PreviewHelperTest < ActiveSupport::TestCase
  def test_returns_template_data_with_no_template
    template_identifier = "preview/no_template"

    expected_template_source = "expected_template"
    mock_template = Minitest::Mock.new
    mock_template.expect(:source, expected_template_source)
    mock_template.expect(:source, expected_template_source)
    mock_template.expect(:identifier, "unknown")

    lookup_context = Minitest::Mock.new
    lookup_context.expect(:find_template, mock_template, [template_identifier])

    template_data = PreviewHelper.find_template_data_for_preview_source(
      lookup_context: lookup_context,
      template_identifier: template_identifier
    )

    assert_equal(template_data[:source], "expected_template")
    assert_equal(template_data[:prism_language_name], "ruby")
  end

  def test_returns_template_data_with_template_of_different_languages
    template_identifier = "preview/template"

    expected_template_source = "expected_template"

    PreviewHelper::AVAILABLE_PRISM_LANGUAGES.each do |language|
      mock_template = Minitest::Mock.new
      mock_template.expect(:source, expected_template_source)
      mock_template.expect(:source, expected_template_source)
      mock_template.expect(:identifier, "html.#{language}")

      lookup_context = Minitest::Mock.new
      lookup_context.expect(:find_template, mock_template, [template_identifier])

      template_data = PreviewHelper.find_template_data_for_preview_source(
        lookup_context: lookup_context,
        template_identifier: template_identifier
      )

      assert_equal(template_data[:source], "expected_template")
      assert_equal(template_data[:prism_language_name], language)
    end
  end
end
