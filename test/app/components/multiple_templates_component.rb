# frozen_string_literal: true

class MultipleTemplatesComponent < ViewComponent::Base
  def initialize(mode:)
    @mode = mode

    @items = ["Apple", "Banana", "Pear"]
  end

  def call
    case @mode
    when :list
      call_list
    when :summary
      call_summary
    end
  end
end
