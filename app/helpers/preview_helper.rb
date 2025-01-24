# frozen_string_literal: true

module PreviewHelper
  AVAILABLE_PRISM_LANGUAGES = %w[ruby erb haml]
  FALLBACK_LANGUAGE = "ruby"

  def preview_source
    return if @render_args.nil?

    render "preview_source"
  end

  def prism_css_source_url
    serve_static_preview_assets? ? asset_path("prism.css", skip_pipeline: true) : "https://cdn.jsdelivr.net/npm/prismjs@1.28.0/themes/prism.min.css"
  end

  def prism_js_source_url
    serve_static_preview_assets? ? asset_path("prism.min.js", skip_pipeline: true) : "https://cdn.jsdelivr.net/npm/prismjs@1.28.0/prism.min.js"
  end

  def find_template_data_for_preview_source(lookup_context:, template_identifier:)
    template = lookup_context.find_template(template_identifier)

    {
      source: template.source,
      prism_language_name: prism_language_name_by_template(template: template)
    }
  end

  private

  def prism_language_name_by_template(template:)
    language = template.identifier.split(".").last

    return FALLBACK_LANGUAGE unless AVAILABLE_PRISM_LANGUAGES.include? language

    language
  end

  # :nocov:
  def prism_language_name_by_template_path(template_file_path:)
    language = template_file_path.gsub(".html", "").split(".").last

    return FALLBACK_LANGUAGE unless AVAILABLE_PRISM_LANGUAGES.include? language

    language
  end
  # :nocov:

  def serve_static_preview_assets?
    ViewComponent::Base.config.show_previews && Rails.application.config.public_file_server.enabled
  end
end
