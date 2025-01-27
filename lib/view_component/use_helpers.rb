# frozen_string_literal: true

require "view_component/errors"

module ViewComponent::UseHelpers
  extend ActiveSupport::Concern

  class_methods do
    def use_helpers(*args, from: nil, prefix: false)
      args.each { |helper_method| use_helper(helper_method, from: from, prefix: prefix) }
    end

    def use_helper(helper_method, from: nil, prefix: false)
      helper_method_name = full_helper_method_name(helper_method, prefix: prefix, source: from)

      class_eval(<<-RUBY, __FILE__, __LINE__ + 1)
        def #{helper_method_name}(*args, &block)
          raise ::ViewComponent::HelpersCalledBeforeRenderError if view_context.nil?

          #{define_helper(helper_method: helper_method, source: from)}
        end
      RUBY
      ruby2_keywords(helper_method_name) if respond_to?(:ruby2_keywords, true)
    end

    private

    def full_helper_method_name(helper_method, prefix: false, source: nil)
      return helper_method unless prefix.present?

      if !!prefix == prefix
        "#{source.to_s.underscore}_#{helper_method}"
      else
        "#{prefix}_#{helper_method}"
      end
    end

    def define_helper(helper_method:, source:)
      return "__vc_original_view_context.#{helper_method}(*args, &block)" unless source.present?

      "#{source}.instance_method(:#{helper_method}).bind(self).call(*args, &block)"
    end
  end
end
