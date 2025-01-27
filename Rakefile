# frozen_string_literal: true

require "bundler/gem_tasks"
require "rake/testtask"
require "yard"
require "yard/mattr_accessor_handler"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/sandbox/**/*_test.rb", "test/view_component/**/*_test.rb"]
end

Rake::TestTask.new(:engine_test) do |t|
  t.libs << "test/test_engine"
  t.libs << "test/test_engine/lib"
  t.test_files = FileList["test/test_engine/**/*_test.rb"]
end

begin
  require "rspec/core/rake_task"
  RSpec::Core::RakeTask.new(:spec)
rescue LoadError
end

desc "Runs benchmarks against components"
task :partial_benchmark do
  ruby "./performance/partial_benchmark.rb"
end

task :translatable_benchmark do
  ruby "./performance/translatable_benchmark.rb"
end

task :slots_benchmark do
  ruby "./performance/slots_benchmark.rb"
end

task :inline_components_benchmark do
  ruby "./performance/inline_benchmark.rb"
end

namespace :coverage do
  task :report do
    require "simplecov"
    require "simplecov-console"

    SimpleCov.minimum_coverage 100

    SimpleCov.collate Dir["{coverage,simplecov-resultset-*}/.resultset.json"], "rails" do
      formatter SimpleCov::Formatter::Console
    end
  end
end

namespace :docs do
  # Build api.md documentation page from YARD comments.
  task :build do
    YARD::Rake::YardocTask.new do |t|
      t.options = ["--no-output"]
    end

    puts "Building YARD documentation."

    Rake::Task["yard"].execute

    puts "Converting YARD documentation to Markdown files."

    registry = YARD::RegistryStore.new
    registry.load!(".yardoc")

    meths =
      registry
        .get("ViewComponent::Base")
        .meths
        .select do |method|
        !method.tag(:private) &&
          method.path.include?("ViewComponent::Base") &&
          method.visibility == :public &&
          !method[:name].to_s.start_with?("_") # Ignore methods we mark as internal by prefixing with underscores
      end.sort_by { |method| method[:name] }

    instance_methods_to_document = meths.select { |method| method.scope != :class }
    class_methods_to_document = meths.select { |method| method.scope == :class }
    configuration_methods_to_document = registry.get("ViewComponent::Config").meths.select(&:reader?)
    test_helper_methods_to_document = registry
      .get("ViewComponent::TestHelpers")
      .meths
      .sort_by { |method| method[:name] }
      .select do |method|
      !method.tag(:private) &&
        method.visibility == :public
    end

    require "rails"
    require "action_controller"
    require "view_component"
    ViewComponent::GlobalConfig.view_component_path = "view_component"
    require "view_component/docs_builder_component"

    error_keys = registry.keys.select { |key| key.to_s.include?("Error::MESSAGE") }.map(&:to_s)

    docs = ActionController::Base.new.render_to_string(
      ViewComponent::DocsBuilderComponent.new(
        sections: [
          ViewComponent::DocsBuilderComponent::Section.new(
            heading: "Class methods",
            methods: class_methods_to_document
          ),
          ViewComponent::DocsBuilderComponent::Section.new(
            heading: "Instance methods",
            methods: instance_methods_to_document
          ),
          ViewComponent::DocsBuilderComponent::Section.new(
            heading: "Configuration",
            methods: configuration_methods_to_document,
            show_types: false
          ),
          ViewComponent::DocsBuilderComponent::Section.new(
            heading: "ViewComponent::TestHelpers",
            methods: test_helper_methods_to_document
          ),
          ViewComponent::DocsBuilderComponent::Section.new(
            heading: "Errors",
            error_klasses: error_keys
          )
        ]
      )
    ).chomp

    File.open("docs/api.md", "w") do |f|
      f.puts(docs)
    end
  end
end

task default: [:test, :engine_test]
