---
layout: default
title: Additional arguments
parent: Rendering collections
nav_order: 2
---

## Additional arguments

Additional arguments besides the collection are passed to each component instance:

`app/view/products/index.html.erb`

```text
<%= render(ProductComponent.with_collection(@products, notice: "hi")) %>
```

`app/components/product_component.rb`

```ruby
class ProductComponent < ViewComponent::Base
  with_collection_parameter :item

  def initialize(item:, notice:)
    @item = item
    @notice = notice
  end
end
```

`app/components/product_component.html.erb`

```text
<li>
  <h2><%= @item.name %></h2>
  <span><%= @notice %></span>
</li>
```
