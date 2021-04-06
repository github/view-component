# frozen_string_literal: true

class TranslatableComponent < ViewComponent::Base
  include ViewComponent::Translatable

  def initialize(key)
    @key = key
  end

  def self.virtual_path
    "/sidecar_i18n_component"
  end
end
