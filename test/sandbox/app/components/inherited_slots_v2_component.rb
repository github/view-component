# frozen_string_literal: true

class InheritedSlotsV2Component < SlotsV2Component
  renders_one :title, -> { "title override" }
end
