# frozen_string_literal: true

class SkipBeforeRenderComponent < BeforeRenderSymbolComponent
  skip_before_render :ensure_should_render
end
