# frozen_string_literal: true

module PreviewHelper
  AVAILABLE_PRISM_LANGUAGES = ["ruby", "erb", "haml"]
  FALLBACK_LANGUAGE = "ruby"

  def prism_language_name(template:)
    if template.respond_to?(:identifier)
      language = template.identifier.split(".").last
    else
      # Handle case when the template is a path
      language = template.gsub(".html", "").split(".").last
    end

    return FALLBACK_LANGUAGE unless AVAILABLE_PRISM_LANGUAGES.include? language

    language
  end

  def preview_source
    return if @render_args.nil?

    render "preview_source" # rubocop:disable GitHub/RailsViewRenderPathsExist
  end

  def find_template_source(lookup_context:, template_identifier:)
    template = lookup_context.find_template(template_identifier)
    return template if Rails.version.to_f >= 6.1 || template.source.present?

    # Fetch template source via finding it through preview paths
    # to accomodate source view when exclusively using templates
    # for previews for Rails < 6.1.
    all_template_paths = ViewComponent::Base.preview_paths.map do |preview_path|
      Dir.glob("#{preview_path}/**/*")
    end.flatten

    # Search for templates the contain `html`.
    matching_templates = all_template_paths.find_all do |template|
      template =~ /#{template_identifier}*.(html)/
    end

    # In-case of a conflict due to multiple template files with
    # the same name
    raise "found 0 matches for templates for #{template_identifier}." if matching_templates.empty?
    raise "found multiple templates for #{template_identifier}." if matching_templates.size > 1

    File.read(matching_templates.first)
  end
end
