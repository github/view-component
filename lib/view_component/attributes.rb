# frozen_string_literal: true

require "active_support/concern"

# An attributes API for declaratively defining properties a component accepts.
# @example
#   class PostComponent
#     include ViewComponent::Attributes
#
#     requires :title
#     requires :posted_at
#
#     accepts :author, default: NullUser.new
#   end
#
#   <%= render PostComponent.new(title: "foo", posted_at: Date.yesterday) %>
module ViewComponent
  module Attributes
    extend ActiveSupport::Concern

    included do
      class_attribute :_optional_attributes, default: {}
      class_attribute :_required_attributes, default: Set.new
    end

    class_methods do
      def requires(parameter)
        _required_attributes << parameter

        attr_reader parameter
      end

      def accepts(parameter, default: nil)
        _optional_attributes[parameter] = default

        attr_accessor parameter
      end

      def inherited(subclass)
        subclass._optional_attributes = _optional_attributes.dup
        subclass._required_attributes = _required_attributes.dup
        super
      end
    end

    def initialize(**args)
      _construct_attributes(args)
    end

    private

    def _construct_attributes(args)
      _required_attributes.each do |attr|
        if !args.has_key?(attr)
          raise ArgumentError.new("Missing keyword: :#{attr}") # Simulate required kwargs
        end

        instance_variable_set("@#{attr}", args[attr])
      end

      _optional_attributes.each do |attr, default|
        if args.has_key?(attr)
          value = args[attr]
          instance_variable_set("@#{attr}", value)
        else
          value = args[attr]
          instance_variable_set("@#{attr}", default)
        end
      end
    end
  end
end
