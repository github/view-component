# frozen_string_literal: true

source "https://rubygems.org"
gemspec

rails_version = "#{ENV['RAILS_VERSION'] || 'master'}"

gem "capybara", "~> 3"
gem "rails", rails_version == "master" ? { github: "rails/rails" } : rails_version
