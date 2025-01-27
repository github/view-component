# frozen_string_literal: true

require "simplecov"
require "simplecov-console"
require "rails/version"

if ENV["MEASURE_COVERAGE"]
  SimpleCov.start do
    command_name "minitest-rails-engine#{Rails::VERSION::STRING}-ruby#{RUBY_VERSION}"

    formatter SimpleCov::Formatter::Console
  end
end

require "bundler/setup"
require "minitest/autorun"
require "rails"
require "rails/generators"
$LOAD_PATH.unshift "./test/test_engine/lib"
require "test_engine"
require "view_component"

Rails::Generators.namespace = TestEngine

def with_config_option(option_name, new_value, config_entrypoint: ViewComponent::GlobalConfig)
  old_value = config_entrypoint.public_send(option_name)
  config_entrypoint.public_send(:"#{option_name}=", new_value)
  yield
ensure
  config_entrypoint.public_send(:"#{option_name}=", old_value)
end

def with_preview_paths(new_value, &block)
  with_config_option(:preview_paths, new_value, &block)
end
