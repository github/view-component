# frozen_string_literal: true

module ViewComponent::CacheOn
  extend ActiveSupport::Concern

  included do
    def cache_key
      @vc_cache_args = vc_cache_args.map { |method| send(method) } if defined?(vc_cache_args)

      @vc_cache_key = Digest::MD5.hexdigest(@vc_cache_args.join)
    end
  end

  class_methods do
    def cache_on(*args)
      define_method(:vc_cache_args) { args }
    end

    def call
      if cache_key
        Rails.cache.fetch(cache_key) { super }
      else
        super
      end
    end
  end
end
