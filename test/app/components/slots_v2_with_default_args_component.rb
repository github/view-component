# frozen_string_literal: true

class SlotsV2WithDefaultArgsComponent < ViewComponent::Base
  include ViewComponent::SlotableV2

  renders_one :icon, ->(icon: "my-icon") { image_tag(icon) }
end
