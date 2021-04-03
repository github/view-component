---
layout: default
title: Template Inheritance
nav_order: 9
---

## Template Inheritance

Components that subclass another component inherit the parent component's template if they don't define their own template.

```ruby
# If `my_link_component.html.erb` is not defined the component will fall back
# to `LinkComponent`s template
class MyLinkComponent < LinkComponent
end
```
