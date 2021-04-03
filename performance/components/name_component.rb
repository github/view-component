# frozen_string_literal: true

class NameComponent < ViewComponent::Base
  def initialize(name:)
    @name = name
  end
end
