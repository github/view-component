# frozen_string_literal: true

require File.expand_path("../boot", __FILE__)

require "active_model/railtie"
require "action_controller/railtie"
require "action_view/railtie"
require "view_component/engine"
require "sprockets/railtie"

require "haml"
require "slim"
require "jbuilder"

module Dummy
  class Application < Rails::Application
    config.action_controller.asset_host = "http://assets.example.com"
  end
end

Dummy::Application.config.secret_key_base = "foo"

# Do not silence library backtraces in test reports
Rails.backtrace_cleaner.remove_filters!
Rails.backtrace_cleaner.remove_silencers!
