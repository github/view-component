# frozen_string_literal: true

class SlotsV2SlotIndexComponent < ViewComponent::Base
  renders_many :items, "Item"

  class Item < ViewComponent::Base
    attr_reader :id

    def initialize(id:)
      @id = id
    end

    def item_number
      "Slot index: #{slot_index}"
    end
  end
end
