# frozen_string_literal: true

# This code intentionally has a bug where there is an extra comma after the
# :notice reader. `Kernel.silence_warnings` is in place to avoid Ruby emitting
# warnings in test output.
Kernel.silence_warnings do
  class ProductReaderOopsComponent < ViewComponent::Base
    attr_reader :product,
                :notice,

    def initialize(product_reader_oops:)
    end
  end
end
