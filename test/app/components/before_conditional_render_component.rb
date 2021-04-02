# frozen_string_literal: true

class BeforeConditionalRenderComponent < ViewComponent::Base
  before_render do
    throw :abort unless @should_render
  end

  def initialize(should_render:)
    @should_render = should_render
  end
end
