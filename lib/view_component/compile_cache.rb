# frozen_string_literal: true

module ViewComponent
  # Keeps track of which templates have already been compiled
  # This isn't part of the public API
  module CompileCache
    if Rails.version.to_f >= 5.2
      mattr_accessor :cache, instance_reader: false, instance_accessor: false, default: Set.new
    else
      mattr_accessor :cache, instance_reader: false, instance_accessor: false do
        Set.new
      end
    end

    module_function

    def register(klass)
      cache << klass
    end

    def compiled?(klass)
      cache.include? klass
    end

    def invalidate_class!(klass)
      cache.delete(klass)
    end

    def invalidate!
      cache.clear
    end
  end
end
