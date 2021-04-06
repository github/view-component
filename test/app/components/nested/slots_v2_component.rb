# frozen_string_literal: true

module Nested
  class SlotsV2Component < ViewComponent::Base
    renders_many :items, "MyHighlightComponent"

    class MyHighlightComponent < ViewComponent::Base
      renders_one :thing, "AnotherComponent"

      class AnotherComponent < ViewComponent::Base
      end
    end
  end
end
