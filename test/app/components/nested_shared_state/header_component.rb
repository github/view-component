# frozen_string_literal: true

module NestedSharedState
  class HeaderComponent < ViewComponent::Base
    renders_many :cells, NestedSharedState::CellComponent

    def initialize(selectable: false, class_names: "table__header", **kwargs)
      @selectable = selectable
      @tag_arguments = kwargs
      @tag_arguments[:class] = class_names
    end
  end
end
