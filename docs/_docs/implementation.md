---
layout: default
title: Implementation
nav_order: 5
---

## Implementation

A ViewComponent is a Ruby file and corresponding template file with the same base name:

`app/components/test_component.rb`:

```ruby
class TestComponent < ViewComponent::Base
  def initialize(title:)
    @title = title
  end
end
```

`app/components/test_component.html.erb`:

```text
<span title="<%= @title %>"><%= content %></span>
```

Rendered in a view as:

```text
<%= render(TestComponent.new(title: "my title")) do %>
  Hello, World!
<% end %>
```

Returning:

```markup
<span title="my title">Hello, World!</span>
```
