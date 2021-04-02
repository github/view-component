# frozen_string_literal: true

class ContentAreasPredicateComponent < ViewComponent::Base
  with_content_areas :title

  def initialize(title: nil, footer: nil)
    @title = title
    @footer = footer
  end

  def render?
    title.present?
  end

  def call
    content_tag :div do
      content_tag :h1, title
    end
  end
end
