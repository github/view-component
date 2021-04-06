# frozen_string_literal: true
#
class LabelComponent < ViewComponent::Base
  def initialize(form:)
    @form = form
  end

  private

  attr_reader :form
end
