# frozen_string_literal: true
require "action_view"
require "active_support/dependencies/autoload"

module ViewComponent
  extend ActiveSupport::Autoload

  autoload :Base
  autoload :Compiler
  autoload :Deprecation
  autoload :Preview
  autoload :PreviewTemplateError
  autoload :TestHelpers
  autoload :TestCase
  autoload :TemplateError
  autoload :Translatable
end
