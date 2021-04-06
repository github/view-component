# frozen_string_literal: true

class CustomTestControllerComponent < ViewComponent::Base
  def call
    helpers.foo
  end
end
