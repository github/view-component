# frozen_string_literal: true

class SleepComponent < ViewComponent::Base
  def initialize(seconds:)
    @seconds = seconds
  end

  def call
    sleep @seconds
    "sleep!"
  end
end
