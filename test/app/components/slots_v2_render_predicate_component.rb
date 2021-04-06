# frozen_string_literal: true

class SlotsV2RenderPredicateComponent < ViewComponent::Base
  renders_one :title, "PredicateTitleComponent"

  def render?
    title.present?
  end

  def call
    content_tag :div do
      title.to_s
    end
  end

  class PredicateTitleComponent < ViewComponent::Base
    def call
      content_tag :h1, content
    end
  end
end
