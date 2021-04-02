# frozen_string_literal: true

class BeforeRenderSymbolComponent < ViewComponent::Base
  before_render :ensure_should_render

  def initialize(should_render:)
    @should_render = should_render
  end

  private

  def ensure_should_render
    throw :abort unless @should_render
  end
end
