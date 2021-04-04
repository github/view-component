# frozen_string_literal: true

class TitleWrapperComponent < ViewComponent::Base
  def initialize(content:)
    @content = content
  end
end
