# frozen_string_literal: true

class SlimRendersManyComponent < ViewComponent::Base
  include ViewComponent::SlotableV2

  renders_many :slim_components, SlimComponent
end
