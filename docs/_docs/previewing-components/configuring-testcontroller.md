---
layout: default
title: Configuring TestController
parent: Previewing Components
nav_order: 1
---

## Configuring TestController

Component tests assume the existence of an `ApplicationController` class, which be can be configured using the `test_controller` option:

`config/application.rb`

```ruby
config.view_component.test_controller = "BaseController"
```
