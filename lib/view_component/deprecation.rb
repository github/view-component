# frozen_string_literal: true

module ViewComponent
  # ViewComponent should warn consumers when they are using a deprecated method.
  # In local development, however, those deprecation warnings are distracting.
  # This class wraps the deprecation warning functionality in some basic logic
  # so the deprecation warnings are only shown to consumers.
  class Deprecation
    def self.warn(message)
      new.warn(message)
    end

    def initialize
      @deprecation_class = if local_test_env?
                             NoopDeprecation
                           else
                             ActiveSupport::Deprecation
                           end
    end

    def warn(message)
      @deprecation_class.warn(message)
    end

    private

    def local_test_env?
      ENV["VIEW_COMPONENT_ENV"] == "test"
    end
  end

  class NoopDeprecation
    def self.warn(_); end
  end
end
