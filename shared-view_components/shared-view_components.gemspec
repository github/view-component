require_relative "lib/shared/view_components/version"

Gem::Specification.new do |spec|
  spec.name        = "shared-view_components"
  spec.version     = Shared::ViewComponents::VERSION
  spec.authors     = ["GitHub Open Source", "Eric Berry"]
  spec.email       = ["opensource+view_component@github.com", "eric@berry.sh"]
  spec.homepage    = "https://github.com/github/view_component"
  spec.summary     = "Shared View Components"
  spec.description = "Shared View Components"
  spec.license     = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = spec.homepage

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency "rails", "~> 6.1.4"
  spec.add_dependency "view_component", ">= 2.32"
end
