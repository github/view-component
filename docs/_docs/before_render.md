---
layout: default
title: before_render
nav_order: 12
---
## before_render

Components can define a `before_render` method to be called before a component is rendered, when `helpers` is able to be used:

`app/components/confirm_email_component.rb`

```ruby
class MyComponent < ViewComponent::Base
  def before_render
    @my_icon = helpers.star_icon
  end
end
```
