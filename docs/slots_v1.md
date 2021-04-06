---
nav_exclude: true
---

# Slots V1 (deprecated)

_Slots V1 is now deprecated and will be removed in 3.0. Please migrate to [Slots V2](/index.md#slots)_

Slots enable multiple blocks of content to be passed to a single ViewComponent, reducing the need for sub-components (e.g. ModalHeader, ModalBody).

By default, slots can be rendered once per component. They provide an accessor with the name of the slot (`#header`) that returns an instance of `ViewComponent::Slot`, etc.

Slots declared with `collection: true` can be rendered multiple times. They provide an accessor with the pluralized name of the slot (`#rows`), which is an Array of `ViewComponent::Slot` instances.

To learn more about the design of the Slots API, see [#348](https://github.com/github/view_component/pull/348) and [#325](https://github.com/github/view_component/discussions/325).

## Defining Slots

Slots are defined by `with_slot`:

`with_slot :header`

To define a collection slot, add `collection: true`:

`with_slot :row, collection: true`

To define a slot with a custom Ruby class, pass `class_name`:

`with_slot :body, class_name: 'BodySlot'`

_Note: Slot classes must be subclasses of `ViewComponent::Slot`._

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

```erb
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

```erb
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
