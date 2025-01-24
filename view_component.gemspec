# frozen_string_literal: true

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "view_component/version"

Gem::Specification.new do |spec|
  spec.name = "view_component"
  spec.version = ViewComponent::VERSION::STRING
  spec.author = "ViewComponent Team"

  spec.summary = "A framework for building reusable, testable & encapsulated view components in Ruby on Rails."
  spec.homepage = "https://viewcomponent.org"
  spec.license = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "https://rubygems.org"
    spec.metadata["source_code_uri"] = "https://github.com/viewcomponent/view_component"
    spec.metadata["changelog_uri"] = "https://github.com/ViewComponent/view_component/blob/main/docs/CHANGELOG.md"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files = Dir["LICENSE.txt", "README.md", "app/**/*", "docs/CHANGELOG.md", "lib/**/*"]
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 3.2.0"

  spec.add_runtime_dependency "activesupport", [">= 7.1.0", "< 8.1"]
  spec.add_runtime_dependency "method_source", "~> 1.0"
  spec.add_runtime_dependency "concurrent-ruby", "1.3.4" # lock version that supports Rails 6.1
  spec.add_development_dependency "allocation_stats", "~> 0.1.5"
  spec.add_development_dependency "appraisal", "~> 2.4"
  spec.add_development_dependency "benchmark-ips", "~> 2.13.0"
  spec.add_development_dependency "better_html"
  spec.add_development_dependency "bundler", "~> 2"
  spec.add_development_dependency "capybara", "~> 3"
  spec.add_development_dependency "cuprite", "~> 0.15"
  spec.add_development_dependency "debug"
  spec.add_development_dependency "erb_lint"
  spec.add_development_dependency "haml", "~> 6"
  spec.add_development_dependency "jbuilder", "~> 2"
  spec.add_development_dependency "m", "~> 1"
  spec.add_development_dependency "minitest", "~> 5.18"
  spec.add_development_dependency "pry", "~> 0.13"
  spec.add_development_dependency "puma", "~> 6"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec-rails", "~> 5"
  spec.add_development_dependency "rubocop-md", "~> 1"
  spec.add_development_dependency "selenium-webdriver", "4.9.0"
  spec.add_development_dependency "sprockets-rails", "~> 3.4.2"
  spec.add_development_dependency "standard", "~> 1"
  spec.add_development_dependency "simplecov", "~> 0.22.0"
  spec.add_development_dependency "simplecov-console", "~> 0.9.1"
  spec.add_development_dependency "slim", "~> 5.1"
  spec.add_development_dependency "turbo-rails", "~> 1"
  spec.add_development_dependency "warning"
  spec.add_development_dependency "yard", "~> 0.9.34"
  spec.add_development_dependency "yard-activesupport-concern", "~> 0.0.1"

  spec.add_development_dependency "net-imap"
  spec.add_development_dependency "net-pop"
  spec.add_development_dependency "net-smtp"

  if RUBY_VERSION >= "3.3"
    spec.add_development_dependency "base64"
    spec.add_development_dependency "bigdecimal"
    spec.add_development_dependency "drb"
    spec.add_development_dependency "mutex_m"
    spec.add_development_dependency "propshaft", "~> 1.1.0"
  end
end
