---
layout: default
title: Preview templates
parent: Previewing Components
nav_order: 3
---

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

```text
<table class="table">
  <tbody>
    <tr>
      <%= render CellComponent.new %>
    </tr>
  </tbody>
</div>
```

To use a different location for preview templates, pass the `template` argument: \(the path should be relative to `config.view_component.preview_path`\):

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

Which enables passing in a value with [http://localhost:3000/rails/components/cell\_component/default?title=Custom+title&subtitle=Another+subtitle](http://localhost:3000/rails/components/cell_component/default?title=Custom+title&subtitle=Another+subtitle).
