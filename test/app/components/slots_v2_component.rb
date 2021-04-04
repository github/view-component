# frozen_string_literal: true

class SlotsV2Component < ViewComponent::Base
  include ViewComponent::SlotableV2

  renders_one :title
  renders_one :subtitle
  renders_one :footer, -> (classes: "", &block) do
    content_tag :footer, class: "footer #{classes}" do
      block.call if block
    end
  end

  renders_many :tabs

  renders_many :items, -> (highlighted: false) do
    MyHighlightComponent.new(highlighted: highlighted)
  end

  def initialize(classes: "")
    @classes = classes
  end

  class MyHighlightComponent < ViewComponent::Base
    def initialize(highlighted: false)
      @highlighted = highlighted
    end

    def classes
      @highlighted ? "highlighted" : "normal"
    end
  end
end
