# frozen_string_literal: true

class GlobalI18nComponent < ViewComponent::Base
  def initialize(key)
    @key = key
  end
end
