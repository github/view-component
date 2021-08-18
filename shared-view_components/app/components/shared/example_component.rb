# frozen_string_literal: true

class Shared::ExampleComponent < ViewComponent::Base
  def initialize(title:)
    @title = title
  end
end
