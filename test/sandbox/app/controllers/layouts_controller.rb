# frozen_string_literal: true

# Tests for render with/without layouts
class LayoutsController < ActionController::Base
  layout "global_for_action", only: :global_for_action

  def default
    render(MyComponent.new)
  end

  def global_for_action
    render(MyComponent.new)
  end

  def explicit_in_action
    render(MyComponent.new, layout: "explicit_in_action")
  end

  def disabled_in_action
    render(MyComponent.new, layout: false)
  end

  def with_content_for
    render(ContentForComponent.new, layout: "with_content_for")
  end
end
