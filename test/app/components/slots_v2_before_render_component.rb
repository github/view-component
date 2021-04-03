# frozen_string_literal: true

class SlotsV2BeforeRenderComponent < ViewComponent::Base
  renders_one :title, "MyTitleComponent"
  renders_many :greetings, "MyGreetingComponent"

  class MyTitleComponent < ViewComponent::Base
    attr_reader :prefix

    def before_render
      @prefix = "Testing"
    end
  end

  class MyGreetingComponent < ViewComponent::Base
    attr_reader :greeting

    def before_render
      @greeting = "Hello,"
    end
  end
end
