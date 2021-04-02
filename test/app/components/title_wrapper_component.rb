# frozen_string_literal: true

class TitleWrapperComponent < ViewComponent::Base
  def initialize(title:)
    @title = title
  end
end
