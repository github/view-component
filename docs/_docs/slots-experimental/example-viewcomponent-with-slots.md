---
layout: default
title: Example ViewComponent with Slots
parent: Slots (experimental)
nav_order: 3
---

## Example ViewComponent with Slots

`# box_component.rb`

```ruby
class BoxComponent < ViewComponent::Base
  include ViewComponent::Slotable

  with_slot :body, :footer
  with_slot :header, class_name: "Header"
  with_slot :row, collection: true, class_name: "Row"

  class Header < ViewComponent::Slot
    def initialize(classes: "")
      @classes = classes
    end

    def classes
      "Box-header #{@classes}"
    end
  end

  class Row < ViewComponent::Slot
    def initialize(theme: :gray)
      @theme = theme
    end

    def theme_class_name
      case @theme
      when :gray
        "Box-row--gray"
      when :hover_gray
        "Box-row--hover-gray"
      when :yellow
        "Box-row--yellow"
      when :blue
        "Box-row--blue"
      when :hover_blue
        "Box-row--hover-blue"
      else
        "Box-row--gray"
      end
    end
  end
end
```

`# box_component.html.erb`

```text
<div class="Box">
  <% if header %>
    <div class="<%= header.classes %>">
      <%= header.content %>
    </div>
  <% end %>
  <% if body %>
    <div class="Box-body">
      <%= body.content %>
    </div>
  <% end %>
  <% if rows.any? %>
    <ul>
      <% rows.each do |row| %>
        <li class="Box-row <%= row.theme_class_name %>">
          <%= row.content %>
        </li>
      <% end %>
    </ul>
  <% end %>
  <% if footer %>
    <div class="Box-footer">
      <%= footer.content %>
    </div>
  <% end %>
</div>
```

`# index.html.erb`

```text
<%= render(BoxComponent.new) do |component| %>
  <% component.slot(:header, classes: "my-class-name") do %>
    This is my header!
  <% end %>
  <% component.slot(:body) do %>
    This is the body.
  <% end %>
  <% component.slot(:row) do %>
    Row one
  <% end %>
  <% component.slot(:row, theme: :yellow) do %>
    Yellow row
  <% end %>
  <% component.slot(:footer) do %>
    This is the footer.
  <% end %>
<% end %>
```
