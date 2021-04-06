# frozen_string_literal: true

class ConditionalContentComponent < ViewComponent::Base
  def render?
    content.present?
  end

  def call
    content
  end
end
