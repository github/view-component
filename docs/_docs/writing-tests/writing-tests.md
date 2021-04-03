---
layout: default
title: Writing tests
nav_order: 15
has_children: true
permalink: /docs/writing-tests
---

## Writing tests

Unit test components directly, using the `render_inline` test helper, asserting against the rendered output.

Capybara matchers are available if the gem is installed:

```ruby
require "view_component/test_case"

class MyComponentTest < ViewComponent::TestCase
  def test_render_component
    render_inline(TestComponent.new(title: "my title")) { "Hello, World!" }

    assert_selector("span[title='my title']", text: "Hello, World!")
    # or, to just assert against the text:
    assert_text("Hello, World!")
  end
end
```

In the absence of `capybara`, assert against the return value of `render_inline`, which is an instance of `Nokogiri::HTML::DocumentFragment`:

```ruby
def test_render_component
  result = render_inline(TestComponent.new(title: "my title")) { "Hello, World!" }

  assert_includes result.css("span[title='my title']").to_html, "Hello, World!"
end
```

Alternatively, assert against the raw output of the component, which is exposed as `rendered_component`:

```ruby
def test_render_component
  render_inline(TestComponent.new(title: "my title")) { "Hello, World!" }

  assert_includes rendered_component, "Hello, World!"
end
```

To test components that use `with_content_areas`:

```ruby
def test_renders_content_areas_template_with_content
  render_inline(ContentAreasComponent.new(footer: "Bye!")) do |component|
    component.with(:title, "Hello!")
    component.with(:body) { "Have a nice day." }
  end

  assert_selector(".title", text: "Hello!")
  assert_selector(".body", text: "Have a nice day.")
  assert_selector(".footer", text: "Bye!")
end
```
