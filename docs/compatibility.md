---
layout: default
title: Compatibility
---

# Compatibility

ViewComponent is [supported natively](https://edgeguides.rubyonrails.org/layouts_and_rendering.html#rendering-objects) in Rails 6.1, and compatible with Rails 5.0+ via an included [monkey patch](https://github.com/github/view_component/blob/main/lib/view_component/render_monkey_patch.rb).

ViewComponent is tested for compatibility [with combinations of](https://github.com/github/view_component/blob/22e3d4ccce70d8f32c7375e5a5ccc3f70b22a703/.github/workflows/ruby_on_rails.yml#L10-L11) Ruby 2.4+ and Rails 5+.

## Disabling the render monkey patch (Rails < 6.1)

In order to [avoid conflicts](https://github.com/github/view_component/issues/288) between ViewComponent and other gems that also monkey patch the `render` method, it is possible to configure ViewComponent to not include the render monkey patch:

`config.view_component.render_monkey_patch_enabled = false # defaults to true`

With the monkey patch disabled, use `render_component` (or  `render_component_to_string`) instead:

```erb
<%= render_component Component.new(message: "bar") %>
```
