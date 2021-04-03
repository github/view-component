# frozen_string_literal: true

require "rails/application_controller"

class ViewComponentsController < Rails::ApplicationController # :nodoc:
  prepend_view_path File.expand_path("../views", __dir__)

  around_action :set_locale, only: :previews
  before_action :find_preview, only: :previews
  before_action :require_local!, unless: :show_previews?

  if respond_to?(:content_security_policy)
    content_security_policy(false)
  end

  def index
    @previews = ViewComponent::Preview.all
    @page_title = "Component Previews"
    render "view_components/index", **determine_layout
  end

  def previews
    if params[:path] == @preview.preview_name
      @page_title = "Component Previews for #{@preview.preview_name}"
      render "view_components/previews", **determine_layout
    else
      prepend_application_view_paths
      prepend_preview_examples_view_path
      @example_name = File.basename(params[:path])
      @render_args = @preview.render_args(@example_name, params: params.permit!)
      layout = determine_layout(@render_args[:layout], prepend_views: false)[:layout]
      template = @render_args[:template]
      locals = @render_args[:locals]
      opts = {}
      opts[:layout] = layout if layout.present? || layout == false
      opts[:locals] = locals if locals.present?
      render template, opts # rubocop:disable GitHub/RailsControllerRenderLiteral
    end
  end

  private

  def default_preview_layout # :doc:
    ViewComponent::Base.default_preview_layout
  end

  def show_previews? # :doc:
    ViewComponent::Base.show_previews
  end

  def find_preview # :doc:
    candidates = []
    params[:path].to_s.scan(%r{/|$}) { candidates << $` }
    preview = candidates.detect { |candidate| ViewComponent::Preview.exists?(candidate) }

    if preview
      @preview = ViewComponent::Preview.find(preview)
    else
      raise AbstractController::ActionNotFound, "Component preview '#{params[:path]}' not found"
    end
  end

  def set_locale
    I18n.with_locale(params[:locale] || I18n.default_locale) do
      yield
    end
  end

  # Returns either {} or {layout: value} depending on configuration
  def determine_layout(layout_override = nil, prepend_views: true)
    return {} unless defined?(Rails.root)

    layout_declaration = {}

    if !layout_override.nil?
      # Allow component-level override, even if false (thus no layout rendered)
      layout_declaration[:layout] = layout_override
    elsif default_preview_layout.present?
      layout_declaration[:layout] = default_preview_layout
    end

    prepend_application_view_paths if layout_declaration[:layout].present? && prepend_views

    layout_declaration
  end

  def prepend_application_view_paths
    prepend_view_path Rails.root.join("app/views") if defined?(Rails.root)
  end

  def prepend_preview_examples_view_path
    prepend_view_path(ViewComponent::Base.preview_paths)
  end
end
