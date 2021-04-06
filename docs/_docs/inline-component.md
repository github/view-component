---
layout: default
title: Inline Component
nav_order: 8
---

## Inline Component

ViewComponents can render without a template file, by defining a `call` method:

`app/components/inline_component.rb`:

```ruby
class InlineComponent < ViewComponent::Base
  def call
    if active?
      link_to "Cancel integration", integration_path, method: :delete
    else
      link_to "Integrate now!", integration_path
    end
  end
end
```

It is also possible to define methods for variants:

```ruby
class InlineVariantComponent < ViewComponent::Base
  def call_phone
    link_to "Phone", phone_path
  end

  def call
    link_to "Default", default_path
  end
end
```

And render them `with_variant`:

```text
<%= render InlineVariantComponent.new.with_variant(:phone) %>

# output: <%= link_to "Phone", phone_path %>
```
