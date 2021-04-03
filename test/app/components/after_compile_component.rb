# frozen_string_literal: true

class AfterCompileComponent < ViewComponent::Base
  @@compiled_value = ""

  def self._after_compile
    @@compiled_value = "Hello, World!"
  end

  def self.compiled_value
    @@compiled_value
  end

  def call
    @@compiled_value
  end
end
