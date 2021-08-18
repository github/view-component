# frozen_string_literal: true

require "rails"
require "view_component"

module ViewComponent
  class Engine < Rails::Engine # :nodoc:
    config.view_component = ActiveSupport::OrderedOptions.new
    config.view_component.preview_paths ||= []

    initializer "view_component.set_configs" do |app|
      options = app.config.view_component

      options.render_monkey_patch_enabled = true if options.render_monkey_patch_enabled.nil?
      options.show_previews = Rails.env.development? || Rails.env.test? if options.show_previews.nil?
      options.instrumentation_enabled = false if options.instrumentation_enabled.nil?
      options.preview_route ||= ViewComponent::Base.preview_route
      options.preview_controller ||= ViewComponent::Base.preview_controller
      options.fragment_caching_enabled ||= false

      if options.show_previews
        options.preview_paths << "#{Rails.root}/test/components/previews" if defined?(Rails.root) && Dir.exist?(
          "#{Rails.root}/test/components/previews"
        )

        if options.preview_path.present?
          ActiveSupport::Deprecation.warn(
            "`preview_path` will be removed in v3.0.0. Use `preview_paths` instead."
          )
          options.preview_paths << options.preview_path
        end
      end

      ActiveSupport.on_load(:view_component) do
        options.each { |k, v| send("#{k}=", v) if respond_to?("#{k}=") }
      end
    end

    initializer "view_component.enable_instrumentation" do |app|
      ActiveSupport.on_load(:view_component) do
        if app.config.view_component.instrumentation_enabled.present?
          # :nocov:
          ViewComponent::Base.prepend(ViewComponent::Instrumentation)
          # :nocov:
        end
      end
    end

    initializer "view_component.set_autoload_paths" do |app|
      options = app.config.view_component

      if options.show_previews && !options.preview_paths.empty?
        ActiveSupport::Dependencies.autoload_paths.concat(options.preview_paths)
      end
    end

    initializer "view_component.eager_load_actions" do
      ActiveSupport.on_load(:after_initialize) do
        ViewComponent::Base.descendants.each(&:compile) if Rails.application.config.eager_load
      end
    end

    initializer "view_component.compile_config_methods" do
      ActiveSupport.on_load(:view_component) do
        config.compile_methods! if config.respond_to?(:compile_methods!)
      end
    end

    initializer "view_component.monkey_patch_render" do |app|
      next if Rails.version.to_f >= 6.1 || !app.config.view_component.render_monkey_patch_enabled

      ActiveSupport.on_load(:action_view) do
        require "view_component/render_monkey_patch"
        ActionView::Base.prepend ViewComponent::RenderMonkeyPatch
      end

      ActiveSupport.on_load(:action_controller) do
        require "view_component/rendering_monkey_patch"
        require "view_component/render_to_string_monkey_patch"
        ActionController::Base.prepend ViewComponent::RenderingMonkeyPatch
        ActionController::Base.prepend ViewComponent::RenderToStringMonkeyPatch
      end
    end

    initializer "view_component.include_render_component" do |app|
      next if Rails.version.to_f >= 6.1

      ActiveSupport.on_load(:action_view) do
        require "view_component/render_component_helper"
        ActionView::Base.include ViewComponent::RenderComponentHelper
      end

      ActiveSupport.on_load(:action_controller) do
        require "view_component/rendering_component_helper"
        require "view_component/render_component_to_string_helper"
        ActionController::Base.include ViewComponent::RenderingComponentHelper
        ActionController::Base.include ViewComponent::RenderComponentToStringHelper
      end
    end

    initializer "static assets" do |app|
      if app.config.view_component.show_previews
        app.middleware.insert_before(::ActionDispatch::Static, ::ActionDispatch::Static, "#{root}/app/assets/vendor")
      end
    end

    initializer "view_component.fragment_caching" do |app|
      next unless app.config.view_component.fragment_caching_enabled

      if Rails.version.to_f < 6.0
        logger.error "Fragment Caching with ViewComponent is not supported in Rails < 6.0"
        next
      end

      ActionController::Base.view_paths.unshift ViewComponent::Base.view_component_path

      if Rails.version.to_f >= 6.1
        Mime::Type.register "text/ruby", :rb
      end

      ActiveSupport.on_load(:action_view) do
        require "view_component/caching/digestor_monkey_patch"
        require "view_component/caching/erb_tracker"
        require "view_component/caching/component_tracker"

        # Patch ActionView::Digestor so it's aware of components
        ActionView::Digestor.prepend ViewComponent::Caching::DigestorMonkeyPatch

        # Unregister default dependency tracker
        ActionView::DependencyTracker.remove_tracker ActionView::Template.handler_for_extension(:erb)

        # Register alternate dependency trackers for both regular rails views and components
        ActionView::DependencyTracker.register_tracker :erb, ViewComponent::Caching::ERBTracker
        ActionView::DependencyTracker.register_tracker :rb, ViewComponent::Caching::ComponentTracker
      end
    end

    config.after_initialize do |app|
      options = app.config.view_component

      if options.show_previews
        app.routes.prepend do
          preview_controller = options.preview_controller.sub(/Controller$/, "").underscore

          get(
            options.preview_route,
            to: "#{preview_controller}#index",
            as: :preview_view_components,
            internal: true
          )

          get(
            "#{options.preview_route}/*path",
            to: "#{preview_controller}#previews",
            as: :preview_view_component,
            internal: true
          )
        end
      end

      app.executor.to_run :before do
        CompileCache.invalidate! unless ActionView::Base.cache_template_loading
      end
    end
  end
end
