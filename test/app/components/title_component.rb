# frozen_string_literal: true

class TitleComponent < ViewComponent::Base
  include ViewComponent::SlotableV2

  renders_one :content
end
