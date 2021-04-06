# frozen_string_literal: true
require "simplecov"
require "simplecov-console"

if ENV["MEASURE_COVERAGE"]
  SimpleCov.start do
    command_name "rails#{ENV["RAILS_VERSION"]}-ruby#{ENV["RUBY_VERSION"]}" if ENV["RUBY_VERSION"]

    formatter SimpleCov::Formatter::Console
  end
end

require "bundler/setup"
require "pp"
require "pathname"
require "minitest/autorun"

# Configure Rails Envinronment
ENV["RAILS_ENV"] = "test"
ENV["VIEW_COMPONENT_ENV"] = "test"

require File.expand_path("../config/environment.rb", __FILE__)
require "rails/test_help"

# Sets custom preview paths in tests.
#
# @param new_value [Array<String>] List of preview paths
# @yield Test code to run
# @return [void]
def with_preview_paths(new_value)
  old_value = Rails.application.config.view_component.preview_paths
  Rails.application.config.view_component.preview_paths = new_value
  yield
  Rails.application.config.view_component.preview_paths = old_value
end

def with_preview_route(new_value)
  old_value = Rails.application.config.view_component.preview_route
  Rails.application.config.view_component.preview_route = new_value
  app.reloader.reload!
  yield
  Rails.application.config.view_component.preview_route = old_value
  app.reloader.reload!
end

def with_preview_controller(new_value)
  old_value = Rails.application.config.view_component.preview_controller
  Rails.application.config.view_component.preview_controller = new_value
  app.reloader.reload!
  yield
  Rails.application.config.view_component.preview_controller = old_value
  app.reloader.reload!
end

def modify_file(file, content)
  filename = Rails.root.join(file)
  old_content = File.read(filename)
  begin
    File.open(filename, "wb+") { |f| f.write(content) }
    yield
  ensure
    File.open(filename, "wb+") { |f| f.write(old_content) }
  end
end

def with_default_preview_layout(layout)
  old_value = ViewComponent::Base.default_preview_layout
  ViewComponent::Base.default_preview_layout = layout
  yield
  ViewComponent::Base.default_preview_layout = old_value
end

def with_render_monkey_patch_config(enabled)
  old_default = ViewComponent::Base.render_monkey_patch_enabled
  ViewComponent::Base.render_monkey_patch_enabled = enabled
  yield
ensure
  ViewComponent::Base.render_monkey_patch_enabled = old_default
end
