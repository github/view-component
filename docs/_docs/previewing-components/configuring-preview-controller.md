---
layout: default
title: Configuring preview controller
parent: Previewing Components
nav_order: 2
---

## Configuring preview controller

Previews can be extended to allow users to add authentication, authorization, before actions, or anything that the end user would need to meet their needs using the `preview_controller` option:

`config/application.rb`

```ruby
config.view_component.preview_controller = "MyPreviewController"
```
