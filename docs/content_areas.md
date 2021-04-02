_Note: The content_areas APIs are soft-deprecated, and will soon be deprecated in favor of Slots._

ViewComponents can declare additional content areas. For example:

`app/components/modal_component.rb`:

```ruby
class ModalComponent < ViewComponent::Base
  with_content_areas :header, :body
end
```

`app/components/modal_component.html.erb`:

```erb
<div class="modal">
  <div class="header"><%= header %></div>
  <div class="body"><%= body %></div>
</div>
```

Rendered in a view as:

```erb
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

```html
<div class="modal">
  <div class="header">Hello Jane</div>
  <div class="body"><p>Have a great day.</p></div>
</div>
```
