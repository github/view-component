# frozen_string_literal: true

module NestedSharedState
  class CellComponent < ViewComponent::Base
    def initialize(class_names: "")
      @class_names = "table__cell #{class_names}"
    end

    def call
      content_tag(:div, content, { class: @class_names })
    end
  end
end
