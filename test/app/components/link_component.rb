# frozen_string_literal: true

class LinkComponent < ViewComponent::Base
  attr_reader :name, :url_options, :html_options, :block

  def initialize(name, url_options = nil, html_options = nil, &block)
    @name = name
    @url_options = url_options
    @html_options = html_options
    @block = block
  end
end
