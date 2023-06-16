# frozen_string_literal: true

class SlotsIterationComponent < ViewComponent::Base
  renders_many :numbered_tabs, NumberedTabComponent
  renders_many :numbered_items, "NumberedItemComponent"

  class NumberedItemComponent < ViewComponent::Base
    attr_reader :item_number, :item_iteration, :title

    def initialize(title:, numbered_item_counter:, numbered_item_iteration:)
      @item_number = numbered_item_counter
      @item_iteration = numbered_item_iteration
      @title = title
    end
  end
end