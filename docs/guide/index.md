---
layout: default
title: Building ViewComponents
nav_order: 3
has_children: true
---

# Building ViewComponents

## Conventions

Components are subclasses of `ViewComponent::Base` and live in `app/components`. It's common practice to create and inherit from an `ApplicationComponent` that is a subclass of `ViewComponent::Base`.

Component names end in -`Component`.

Component module names are plural, as for controllers and jobs: `Users::AvatarComponent`

Name components for what they render, not what they accept. (`AvatarComponent` instead of `UserComponent`)

## Quick start

Use the component generator to create a new ViewComponent.

The generator accepts a component name and a list of arguments:

```console
bin/rails generate component Example title

      invoke  test_unit
      create  test/components/example_component_test.rb
      create  app/components/example_component.rb
      create  app/components/example_component.html.erb
```

ViewComponent includes template generators for the `erb`, `haml`, and `slim` template engines and will default to the template engine specified in `config.generators.template_engine`.

The template engine can also be passed as an option to the generator:

```console
bin/rails generate component Example title --template-engine slim
```

To generate a [preview](#previewing-components), pass the `--preview` option:

```console
bin/rails generate component Example title --preview
```

## Implementation

A ViewComponent is a Ruby file and corresponding template file with the same base name:

`app/components/example_component.rb`:

```ruby
class ExampleComponent < ViewComponent::Base
  def initialize(title:)
    @title = title
  end
end
```

`app/components/example_component.html.erb`:

```erb
<span title="<%= @title %>"><%= content %></span>
```

_Content passed to a ViewComponent as a block is captured and assigned to the `content` accessor._

Rendered in a view as:

```erb
<%= render(ExampleComponent.new(title: "my title")) do %>
  Hello, World!
<% end %>
```

Returning:

```html
<span title="my title">Hello, World!</span>
```
