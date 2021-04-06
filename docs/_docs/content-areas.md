---
layout: default
title: Content areas
nav_order: 6
---

## Content Areas

Content passed to a ViewComponent as a block is captured and assigned to the `content` accessor.

ViewComponents can declare additional content areas. For example:

`app/components/modal_component.rb`:

```ruby
class ModalComponent < ViewComponent::Base
  with_content_areas :header, :body
end
```

`app/components/modal_component.html.erb`:

```text
<div class="modal">
  <div class="header"><%= header %></div>
  <div class="body"><%= body %></div>
</div>
```

Rendered in a view as:

```text
<%= render(ModalComponent.new) do |component| %>
  <% component.with(:header) do %>
    Hello Jane
  <% end %>
  <% component.with(:body) do %>
    <p>Have a great day.</p>
  <% end %>
<% end %>
```

Returning:

```markup
<div class="modal">
  <div class="header">Hello Jane</div>
  <div class="body"><p>Have a great day.</p></div>
</div>
```
