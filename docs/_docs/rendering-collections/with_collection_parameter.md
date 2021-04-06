---
layout: default
title: with_collection_parameter
parent: Rendering collections
nav_order: 1
---

## with_collection_parameter

Use `with_collection_parameter` to change the name of the collection parameter:

`app/components/product_component.rb`

```ruby
class ProductComponent < ViewComponent::Base
  with_collection_parameter :item

  def initialize(item:)
    @item = item
  end
end
```
