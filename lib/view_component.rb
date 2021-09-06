# frozen_string_literal: true

require "action_view"
require "active_support/dependencies/autoload"

module ViewComponent
  extend ActiveSupport::Autoload

  autoload :Base
  autoload :Compiler
  autoload :ComponentError
  autoload :Instrumentation
  autoload :Preview
  autoload :PreviewTemplateError
  autoload :TestHelpers
  autoload :SystemTestHelpers
  autoload :TestCase
  autoload :SystemTestCase
  autoload :TemplateError
  autoload :Translatable
end
