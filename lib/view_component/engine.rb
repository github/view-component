# frozen_string_literal: true

require "rails"
require "view_component/config"
require "view_component/deprecation"

module ViewComponent
  class Engine < Rails::Engine # :nodoc:
    config.view_component = ViewComponent::Config.current

    if Rails.version.to_f < 8.0
      rake_tasks do
        load "view_component/rails/tasks/view_component.rake"
      end
    else
      initializer "view_component.stats_directories" do |app|
        require "rails/code_statistics"

        if Rails.root.join(ViewComponent::Base.view_component_path).directory?
          Rails::CodeStatistics.register_directory("ViewComponents", ViewComponent::Base.view_component_path)
        end

        if Rails.root.join("test/components").directory?
          Rails::CodeStatistics.register_directory("ViewComponent tests", "test/components", test_directory: true)
        end
      end
    end

    initializer "view_component.set_configs" do |app|
      options = app.config.view_component

      %i[generate preview_controller preview_route show_previews_source].each do |config_option|
        options[config_option] ||= ViewComponent::Base.public_send(config_option)
      end
      options.instrumentation_enabled = false if options.instrumentation_enabled.nil?
      options.render_monkey_patch_enabled = true if options.render_monkey_patch_enabled.nil?
      options.show_previews = (Rails.env.development? || Rails.env.test?) if options.show_previews.nil?

      if options.show_previews
        # This is still necessary because when `config.view_component` is declared, `Rails.root` is unspecified.
        options.preview_paths << "#{Rails.root}/test/components/previews" if defined?(Rails.root) && Dir.exist?(
          "#{Rails.root}/test/components/previews"
        )

        if options.show_previews_source
          require "method_source"

          app.config.to_prepare do
            MethodSource.instance_variable_set(:@lines_for_file, {})
          end
        end
      end
    end

    initializer "view_component.enable_instrumentation" do |app|
      ActiveSupport.on_load(:view_component) do
        if app.config.view_component.instrumentation_enabled.present?
          # :nocov: Re-executing the below in tests duplicates initializers and causes order-dependent failures.
          ViewComponent::Base.prepend(ViewComponent::Instrumentation)
          if app.config.view_component.use_deprecated_instrumentation_name
            ViewComponent::Deprecation.deprecation_warning(
              "!render.view_component",
              "Use the new instrumentation key `render.view_component` instead. See https://viewcomponent.org/guide/instrumentation.html"
            )
          end
          # :nocov:
        end
      end
    end

    # :nocov:
    initializer "view_component.enable_capture_patch" do |app|
      ActiveSupport.on_load(:view_component) do
        ActionView::Base.include(ViewComponent::CaptureCompatibility) if app.config.view_component.capture_compatibility_patch_enabled
      end
    end
    # :nocov:

    initializer "view_component.set_autoload_paths", before: :set_autoload_paths do |app|
      options = app.config.view_component

      if options.show_previews && !options.preview_paths.empty?
        paths_to_add = options.preview_paths - app.config.autoload_paths
        app.config.autoload_paths.concat(paths_to_add) if paths_to_add.any?
      end
    end

    initializer "view_component.eager_load_actions" do
      ActiveSupport.on_load(:after_initialize) do
        ViewComponent::Base.descendants.each(&:compile) if Rails.application.config.eager_load
      end
    end

    initializer "view_component.monkey_patch_render" do |app|
      next if Rails.version.to_f >= 6.1 || !app.config.view_component.render_monkey_patch_enabled

      # :nocov:
      ViewComponent::Deprecation.deprecation_warning("Monkey patching `render`", "ViewComponent 4.0 will remove the `render` monkey patch")

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
      # :nocov:
    end

    initializer "view_component.include_render_component" do |_app|
      next if Rails.version.to_f >= 6.1

      # :nocov:
      ViewComponent::Deprecation.deprecation_warning("using `render_component`", "ViewComponent 4.0 will remove `render_component`")

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
      # :nocov:
    end

    initializer "static assets" do |app|
      if serve_static_preview_assets?(app.config)
        app.middleware.use(::ActionDispatch::Static, "#{root}/app/assets/vendor")
      end
    end

    def serve_static_preview_assets?(app_config)
      app_config.view_component.show_previews && app_config.public_file_server.enabled
    end

    initializer "compiler mode" do |_app|
      ViewComponent::Compiler.development_mode = (Rails.env.development? || Rails.env.test?)
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

      if Rails.env.test?
        app.routes.prepend do
          get("_system_test_entrypoint", to: "view_components_system_test#system_test_entrypoint")
        end
      end

      # :nocov:
      if RUBY_VERSION < "3.2.0"
        ViewComponent::Deprecation.deprecation_warning("Support for Ruby versions < 3.2.0", "ViewComponent v4 will remove support for Ruby versions < 3.2.0 no earlier than April 1, 2025")
      end

      if Rails.version.to_f < 7.1
        ViewComponent::Deprecation.deprecation_warning("Support for Rails versions < 7.1", "ViewComponent v4 will remove support for Rails versions < 7.1 no earlier than April 1, 2025")
      end
      # :nocov:

      app.executor.to_run :before do
        CompileCache.invalidate! unless ActionView::Base.cache_template_loading
      end
    end
  end
end
