---
layout: default
title: Disabling the render monkey patch (Rails &lt; 6.1)
nav_order: 18
---

## Disabling the render monkey patch (Rails &lt; 6.1)

In order to [avoid conflicts](https://github.com/github/view_component/issues/288) between ViewComponent and other gems that also monkey patch the `render` method, it is possible to configure ViewComponent to not include the render monkey patch:

`config.view_component.render_monkey_patch_enabled = false # defaults to true`

With the monkey patch disabled, use `render_component` \(or `render_component_to_string`\) instead:

```text
<%= render_component Component.new(message: "bar") %>
```
