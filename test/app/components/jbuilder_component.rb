# frozen_string_literal: true

class JbuilderComponent < ViewComponent::Base
  def initialize(message:)
    @message = message
  end
end
