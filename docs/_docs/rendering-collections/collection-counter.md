---
layout: default
title: Collection counter
parent: Rendering collections
nav_order: 3
---

## Collection counter

ViewComponent defines a counter variable matching the parameter name above, followed by `_counter`. To access the variable, add it to `initialize` as an argument:

`app/components/product_component.rb`

```ruby
class ProductComponent < ViewComponent::Base
  def initialize(product:, product_counter:)
    @product = product
    @counter = product_counter
  end
end
```

`app/components/product_component.html.erb`

```text
<li>
  <%= @counter %> <%= @product.name %>
</li>
```
