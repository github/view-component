---
layout: default
title: Action Pack Variants
parent: Writing tests
nav_order: 1
---

## Action Pack Variants

Use the `with_variant` helper to test specific variants:

```ruby
def test_render_component_for_tablet
  with_variant :tablet do
    render_inline(TestComponent.new(title: "my title")) { "Hello, tablets!" }

    assert_selector("span[title='my title']", text: "Hello, tablets!")
  end
end
```
