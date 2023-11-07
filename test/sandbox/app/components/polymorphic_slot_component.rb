# frozen_string_literal: true

class PolymorphicSlotComponent < ViewComponent::Base
  renders_many :fields, types: {
    foo: {renders: "FooItem", as: :foo_field},
    bar: {
      renders: lambda { |class_names: "", **_system_arguments|
        classes = (class_names.split(" ") + ["bar"]).join(" ")
        content_tag(:div, class: classes) do
          "bar item"
        end
      },

      as: :bar_field
    }
  }

  renders_one :header, types: {
    standard: lambda { |&block| content_tag(:div, class: "standard", &block) },
    special: lambda { |&block| content_tag(:div, class: "special", &block) }
  }

  renders_one :footer, types: {
    standard: "StandardFooter",
    special: -> { "special footer" }
  }

  renders_many :items, types: {
    passthrough: "PassthroughItem",
    foo: "FooItem",
    bar: lambda { |class_names: "", **_system_arguments|
      classes = (class_names.split(" ") + ["bar"]).join(" ")
      content_tag(:div, class: classes) do
        "bar item"
      end
    }
  }

  class PassthroughItem < ViewComponent::Base
    def call
      content
    end
  end

  class FooItem < ViewComponent::Base
    def initialize(class_names: "", **_system_arguments)
      @class_names = class_names
    end

    def call
      classes = (@class_names.split(" ") + ["foo"]).join(" ")
      content_tag(:div, class: classes) do
        "foo item"
      end
    end
  end

  class StandardFooter < ViewComponent::Base
    def call
      "standard footer"
    end
  end
end
