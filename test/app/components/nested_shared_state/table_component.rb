# frozen_string_literal: true

module NestedSharedState
  class TableComponent < ViewComponent::Base
    renders_one :header, -> (arg = nil, **system_arguments, &block) do
      header_system_arguments = system_arguments
      header_system_arguments[:selectable] = @selectable

      header_system_arguments[:data] ||= {}
      header_system_arguments[:data][:argument] = arg if arg.present?

      NestedSharedState::HeaderComponent.new(**header_system_arguments)
    end

    def initialize(selectable: false)
      @selectable = selectable
    end
  end
end
