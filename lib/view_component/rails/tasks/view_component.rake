# frozen_string_literal: true

task stats: "view_component:statsetup"

namespace :view_component do
  task :statsetup do
    # :nocov:
    require "rails/code_statistics"

    if Rails.root.join(ViewComponent::GlobalConfig.view_component_path).directory?
      ::STATS_DIRECTORIES << ["ViewComponents", ViewComponent::GlobalConfig.view_component_path]
    end

    if Rails.root.join("test/components").directory?
      ::STATS_DIRECTORIES << ["ViewComponent tests", "test/components"]
      CodeStatistics::TEST_TYPES << "ViewComponent tests"
    end
    # :nocov:
  end
end
