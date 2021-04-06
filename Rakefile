# frozen_string_literal: true

require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/*_test.rb"]
end

desc "Runs benchmarks against components"
task :benchmark do
  ruby "./performance/benchmark.rb"
end

desc "Runs benchmarks against component content area/ slot implementations"
task :slotable_benchmark do
  ruby "./performance/slotable_benchmark.rb"
end

task :translatable_benchmark do
  ruby "./performance/translatable_benchmark.rb"
end

namespace :coverage do
  task :report do
    require "simplecov"
    require "simplecov-console"

    SimpleCov.minimum_coverage 100

    SimpleCov.collate Dir["simplecov-resultset-*/.resultset.json"], "rails" do
      formatter SimpleCov::Formatter::Console
    end
  end
end

task default: :test
