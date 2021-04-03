---
layout: default
title: Collections
parent: Building ViewComponents
---

# Collections

Like [Rails partials](https://guides.rubyonrails.org/layouts_and_rendering.html#rendering-collections), it's possible to render a collection with ViewComponents, using `with_collection`:

`app/view/products/index.html.erb`

``` erb
<%= render(ProductComponent.with_collection(@products)) %>
```

`app/components/product_component.rb`

``` ruby
class ProductComponent < ViewComponent::Base
  def initialize(product:)
    @product = product
  end
end
```

[By default](https://github.com/github/view_component/blob/89f8fab4609c1ef2467cf434d283864b3c754473/lib/view_component/base.rb#L249), the component name is used to define the parameter passed into the component from the collection.

## `with_collection_parameter`

Use `with_collection_parameter` to change the name of the collection parameter:

`app/components/product_component.rb`

``` ruby
class ProductComponent < ViewComponent::Base
  with_collection_parameter :item

  def initialize(item:)
    @item = item
  end
end
```

## Additional arguments

Additional arguments besides the collection are passed to each component instance:

`app/view/products/index.html.erb`

``` erb
<%= render(ProductComponent.with_collection(@products, notice: "hi")) %>
```

`app/components/product_component.rb`

``` ruby
class ProductComponent < ViewComponent::Base
  with_collection_parameter :item

  def initialize(item:, notice:)
    @item = item
    @notice = notice
  end
end
```

`app/components/product_component.html.erb`

``` erb
<li>
  <h2><%= @item.name %></h2>
  <span><%= @notice %></span>
</li>
```

## Collection counter

ViewComponent defines a counter variable matching the parameter name above, followed by `_counter`. To access the variable, add it to `initialize` as an argument:

`app/components/product_component.rb`

``` ruby
class ProductComponent < ViewComponent::Base
  def initialize(product:, product_counter:)
    @product = product
    @counter = product_counter
  end
end
```

`app/components/product_component.html.erb`

``` erb
<li>
  <%= @counter %> <%= @product.name %>
</li>
```
