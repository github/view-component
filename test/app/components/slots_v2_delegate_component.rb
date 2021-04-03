# frozen_string_literal: true

class SlotsV2DelegateComponent < ViewComponent::Base
  renders_many :items, SlotsV2Component::MyHighlightComponent

  def initialize
  end
end
