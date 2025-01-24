# frozen_string_literal: true

class ContainerComponent < ViewComponent::Base
  def call
    render HelpersProxyComponent.new
  end
end
