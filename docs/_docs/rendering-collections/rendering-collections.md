---
layout: default
title: Rendering collections
nav_order: 13
has_children: true
permalink: /docs/rendering-collections
---

## Rendering collections

Use `with_collection` to render a ViewComponent with a collection:

`app/view/products/index.html.erb`

```text
<%= render(ProductComponent.with_collection(@products)) %>
```

`app/components/product_component.rb`

```ruby
class ProductComponent < ViewComponent::Base
  def initialize(product:)
    @product = product
  end
end
```

[By default](https://github.com/github/view_component/blob/89f8fab4609c1ef2467cf434d283864b3c754473/lib/view_component/base.rb#L249), the component name is used to define the parameter passed into the component from the collection.
