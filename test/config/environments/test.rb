# frozen_string_literal: true

Dummy::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # The test environment is used exclusively to run your application's
  # test suite.  You never need to work with it otherwise.  Remember that
  # your test database is "scratch space" for the test suite and is wiped
  # and recreated between test runs.  Don't rely on the data there!
  config.cache_classes = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Raise exceptions instead of rendering exception templates
  config.action_dispatch.show_exceptions = false

  # Disable request forgery protection in test environment
  config.action_controller.allow_forgery_protection    = false

  config.view_component.show_previews = true

  # This line ensures that the old preview_path argument still works.
  # Remove once we land v3.0.0
  config.view_component.preview_path = "#{Rails.root}/lib/component_previews_old"

  config.view_component.preview_paths << "#{Rails.root}/lib/component_previews"
  config.view_component.render_monkey_patch_enabled = true
  config.view_component.test_controller = "IntegrationExamplesController"

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  #config.action_mailer.delivery_method = :test

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Print deprecation notices to the stderr
  config.active_support.deprecation = :stderr

  config.action_view.annotate_rendered_view_with_filenames = true if Rails.version.to_f >= 6.1

  config.eager_load = true
end
