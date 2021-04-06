---
layout: default
title: Previews
parent: Building ViewComponents
---

# Previews

`ViewComponent::Preview`, like `ActionMailer::Preview`, provides a quick way to preview components in isolation.

_For a more interactive experience, consider using [ViewComponent::Storybook](https://github.com/jonspalmer/view_component_storybook)._

Define a `ViewComponent::Preview`:

`test/components/previews/example_component_preview.rb`

```ruby
class ExampleComponentPreview < ViewComponent::Preview
  def with_default_title
    render(ExampleComponent.new(title: "Example component default"))
  end

  def with_long_title
    render(ExampleComponent.new(title: "This is a really long title to see how the component renders this"))
  end

  def with_content_block
    render(ExampleComponent.new(title: "This component accepts a block of content")) do
      tag.div do
        content_tag(:span, "Hello")
      end
    end
  end
end
```

Which generates <http://localhost:3000/rails/view_components/example_component/with_default_title>,
<http://localhost:3000/rails/view_components/example_component/with_long_title>,
and <http://localhost:3000/rails/view_components/example_component/with_content_block>.

It's also possible to set dynamic values from the params by setting them as arguments:

`test/components/previews/example_component_preview.rb`

```ruby
class ExampleComponentPreview < ViewComponent::Preview
  def with_dynamic_title(title: "Example component default")
    render(ExampleComponent.new(title: title))
  end
end
```

Which enables passing in a value with <http://localhost:3000/rails/view_components/example_component/with_dynamic_title?title=Custom+title>.

The `ViewComponent::Preview` base class includes
[`ActionView::Helpers::TagHelper`](https://api.rubyonrails.org/classes/ActionView/Helpers/TagHelper.html), which provides the [`tag`](https://api.rubyonrails.org/classes/ActionView/Helpers/TagHelper.html#method-i-tag)
and [`content_tag`](https://api.rubyonrails.org/classes/ActionView/Helpers/TagHelper.html#method-i-content_tag) view helper methods.

Previews use the application layout by default, but can use a specific layout with the `layout` option:

`test/components/previews/example_component_preview.rb`

```ruby
class ExampleComponentPreview < ViewComponent::Preview
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

Previews are served from <http://localhost:3000/rails/view_components> by default. To use a different endpoint, set the `preview_route` option:

`config/application.rb`

```ruby
config.view_component.preview_route = "/previews"
```

This example will make the previews available from <http://localhost:3000/previews>.

## Preview templates

Given a preview `test/components/previews/cell_component_preview.rb`, template files can be defined at `test/components/previews/cell_component_preview/`:

`test/components/previews/cell_component_preview.rb`

```ruby
class CellComponentPreview < ViewComponent::Preview
  def default
  end
end
```

`test/components/previews/cell_component_preview/default.html.erb`

```erb
<table class="table">
  <tbody>
    <tr>
      <%= render CellComponent.new %>
    </tr>
  </tbody>
</div>
```

To use a different location for preview templates, pass the `template` argument:
(the path should be relative to `config.view_component.preview_path`):

`test/components/previews/cell_component_preview.rb`

```ruby
class CellComponentPreview < ViewComponent::Preview
  def default
    render_with_template(template: 'custom_cell_component_preview/my_preview_template')
  end
end
```

Values from `params` can be accessed through `locals`:

`test/components/previews/cell_component_preview.rb`

```ruby
class CellComponentPreview < ViewComponent::Preview
  def default(title: "Default title", subtitle: "A subtitle")
    render_with_template(locals: {
      title: title,
      subtitle: subtitle
    })
  end
end
```

Which enables passing in a value with <http://localhost:3000/rails/view_components/cell_component/default?title=Custom+title&subtitle=Another+subtitle>.

## Configuring preview controller

Previews can be extended to allow users to add authentication, authorization, before actions, or anything that the end user would need to meet their needs using the `preview_controller` option:

`config/application.rb`

```ruby
config.view_component.preview_controller = "MyPreviewController"
```
