# frozen_string_literal: true

module Nested
  class SlotsV2Component < ViewComponent::Base
    include ViewComponent::SlotableV2

    renders_many :items, "MyHighlightComponent"

    class MyHighlightComponent < ViewComponent::Base
      include ViewComponent::SlotableV2

      renders_one :thing, "AnotherComponent"

      class AnotherComponent < ViewComponent::Base
      end
    end
  end
end
