# frozen_string_literal: true

module ViewComponent
  module VERSION
    MAJOR = 2
    MINOR = 30
    PATCH = 0

    STRING = [MAJOR, MINOR, PATCH].join(".")
  end
end

puts ViewComponent::VERSION::STRING if __FILE__ == $PROGRAM_NAME
