# frozen_string_literal: true

class CacheComponent < ViewComponent::Base
  cache_on :foo, :bar

  attr_reader :foo, :bar

  def initialize(foo:, bar:)
    @foo = foo
    @bar = bar
  end
end
