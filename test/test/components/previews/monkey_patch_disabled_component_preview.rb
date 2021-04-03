# frozen_string_literal: true

class MonkeyPatchDisabledComponentPreview < ViewComponent::Preview
  def default
    render_component(MonkeyPatchDisabledComponent.new(title: "Lorem Ipsum"))
  end
end
