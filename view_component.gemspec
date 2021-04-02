# coding: utf-8
# frozen_string_literal: true

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "view_component/version"

Gem::Specification.new do |spec|
  spec.name          = "view_component"
  spec.version       = ViewComponent::VERSION::STRING
  spec.authors       = ["GitHub Open Source"]
  spec.email         = ["opensource+view_component@github.com"]

  spec.summary       = %q{View components for Rails}
  spec.homepage      = "https://github.com/github/view_component"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "https://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = Dir["CHANGELOG.md", "LICENSE.txt", "README.md", "app/**/*", "lib/**/*"]
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 2.3.0"

  spec.add_runtime_dependency     "activesupport", [">= 5.0.0", "< 7.0"]
  spec.add_development_dependency "benchmark-ips", "~> 2.8.2"
  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "minitest", "= 5.6.0"
  spec.add_development_dependency "haml", "~> 5"
  spec.add_development_dependency "slim", "~> 4.0"
  spec.add_development_dependency "better_html", "~> 1"
  spec.add_development_dependency "jbuilder", "~> 2"
  spec.add_development_dependency "rubocop", "= 0.74"
  spec.add_development_dependency "rubocop-github", "~> 0.13.0"
  spec.add_development_dependency "simplecov", "~> 0.18.0"
  spec.add_development_dependency "simplecov-console", "~> 0.7.2"
  spec.add_development_dependency "pry", "~> 0.13"
end
