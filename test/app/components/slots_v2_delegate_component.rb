# frozen_string_literal: true

class SlotsV2DelegateComponent < ViewComponent::Base
  include ViewComponent::SlotableV2

  renders_many :items, SlotsV2Component::MyHighlightComponent

  def initialize
  end
end
