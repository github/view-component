# frozen_string_literal: true

class SlotComponent < ViewComponent::Base
  include ViewComponent::Slotable

  with_slot :header, class_name: "Header"
  with_slot :item, class_name: "Item", collection: true

  class Header < ViewComponent::Slot
    attr_reader :classes

    def initialize(classes:)
      @classes = classes
    end
  end

  class Item < ViewComponent::Slot
    attr_reader :classes

    def initialize(classes:)
      @classes = classes
    end
  end

  def initialize(name:)
    @name = name
  end
end
