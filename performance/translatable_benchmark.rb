# frozen_string_literal: true

# Run `bundle exec rake benchmark` to execute benchmark.
# This is very much a work-in-progress. Please feel free to make/suggest improvements!

require "benchmark/ips"

# Configure Rails Envinronment
ENV["RAILS_ENV"] = "production"
require File.expand_path("../test/config/environment.rb", __dir__)

require_relative "components/global_i18n_component.rb"
require_relative "components/sidecar_i18n_component.rb"

class BenchmarksController < ActionController::Base
end

BenchmarksController.view_paths = [File.expand_path("./views", __dir__)]
controller_view = BenchmarksController.new.view_context
I18n.load_path = Dir[File.expand_path("../test/config/locales/*.{rb,yml,yaml}", __dir__)]
I18n.backend.load_translations

Benchmark.ips do |x|
  x.report(:global) { controller_view.render(GlobalI18nComponent.new("hello")) }
  x.report(:global_missing) { controller_view.render(GlobalI18nComponent.new("missing")) }
  x.report(:sidecar_absolute) { controller_view.render(TranslatableComponent.new("sidecar_i18n_component.hello")) }
  x.report(:sidecar) { controller_view.render(TranslatableComponent.new(".hello")) }
  x.report(:sidecar_missing) { controller_view.render(TranslatableComponent.new("missing")) }
  x.report(:sidecar_fallback) { controller_view.render(TranslatableComponent.new("from.rails")) }

  x.compare!
end
