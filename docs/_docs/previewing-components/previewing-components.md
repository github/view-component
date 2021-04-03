---
layout: default
title: Previewing Components
nav_order: 16
has_children: true
permalink: /docs/previewing-components
---

## Previewing Components

`ViewComponent::Preview`, like `ActionMailer::Preview`, provides a way to preview components in isolation:

`test/components/previews/test_component_preview.rb`

```ruby
class TestComponentPreview < ViewComponent::Preview
  def with_default_title
    render(TestComponent.new(title: "Test component default"))
  end

  def with_long_title
    render(TestComponent.new(title: "This is a really long title to see how the component renders this"))
  end

  def with_content_block
    render(TestComponent.new(title: "This component accepts a block of content")) do
      tag.div do
        content_tag(:span, "Hello")
      end
    end
  end
end
```

Which generates [http://localhost:3000/rails/view\_components/test\_component/with\_default\_title](http://localhost:3000/rails/view_components/test_component/with_default_title), [http://localhost:3000/rails/view\_components/test\_component/with\_long\_title](http://localhost:3000/rails/view_components/test_component/with_long_title), and [http://localhost:3000/rails/view\_components/test\_component/with\_content\_block](http://localhost:3000/rails/view_components/test_component/with_content_block).

It's also possible to set dynamic values from the params by setting them as arguments:

`test/components/previews/test_component_preview.rb`

```ruby
class TestComponentPreview < ViewComponent::Preview
  def with_dynamic_title(title: "Test component default")
    render(TestComponent.new(title: title))
  end
end
```

Which enables passing in a value with [http://localhost:3000/rails/components/test\_component/with\_dynamic\_title?title=Custom+title](http://localhost:3000/rails/components/test_component/with_dynamic_title?title=Custom+title).

The `ViewComponent::Preview` base class includes [`ActionView::Helpers::TagHelper`](https://api.rubyonrails.org/classes/ActionView/Helpers/TagHelper.html), which provides the [`tag`](https://api.rubyonrails.org/classes/ActionView/Helpers/TagHelper.html#method-i-tag) and [`content_tag`](https://api.rubyonrails.org/classes/ActionView/Helpers/TagHelper.html#method-i-content_tag) view helper methods.

Previews use the application layout by default, but can use a specific layout with the `layout` option:

`test/components/previews/test_component_preview.rb`

```ruby
class TestComponentPreview < ViewComponent::Preview
  layout "admin"

  ...
end
```

You can also set a custom layout to be used by default for previews as well as the preview index pages via the `default_preview_layout` configuration option:

`config/application.rb`

```ruby
# Set the default layout to app/views/layouts/component_preview.html.erb
config.view_component.default_preview_layout = "component_preview"
```

Preview classes live in `test/components/previews`, which can be configured using the `preview_paths` option:

`config/application.rb`

```ruby
config.view_component.preview_paths << "#{Rails.root}/lib/component_previews"
```

Previews are served from [http://localhost:3000/rails/view\_components](http://localhost:3000/rails/view_components) by default. To use a different endpoint, set the `preview_route` option:

`config/application.rb`

```ruby
config.view_component.preview_route = "/previews"
```

This example will make the previews available from [http://localhost:3000/previews](http://localhost:3000/previews).
