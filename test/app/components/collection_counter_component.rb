# frozen_string_literal: true

class CollectionCounterComponent < ViewComponent::Base
  with_collection_parameter :item

  def initialize(item:, item_counter:)
    @item = item
    @counter = item_counter
    @index = @counter - 1
  end
end
