# frozen_string_literal: true

class SlimRendersManyComponent < ViewComponent::Base
  renders_many :slim_components, SlimComponent
end
