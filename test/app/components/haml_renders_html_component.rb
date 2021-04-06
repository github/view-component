# frozen_string_literal: true

class HamlRendersHtmlComponent < ViewComponent::Base
  renders_one :title
  renders_many :posts
end
