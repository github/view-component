require_relative "../../test_helper"

class Shared::ExampleComponentTest < ViewComponent::TestCase
  def test_renders
    assert_equal(
      %(<span title="Hello">World!</span>),
      render_inline(Shared::ExampleComponent.new(title: "Hello").with_content("World!")).css("span").to_html
    )
  end
end
