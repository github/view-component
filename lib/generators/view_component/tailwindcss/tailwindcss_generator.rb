# frozen_string_literal: true

require "generators/view_component/erb/erb_generator"

module ViewComponent
  module Generators
    class TailwindcssGenerator < ViewComponent::Generators::ErbGenerator
      source_root File.expand_path("templates", __dir__)
    end
  end
end
