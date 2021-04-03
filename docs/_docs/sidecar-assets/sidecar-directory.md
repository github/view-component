---
layout: default
title: Sidecar Directory
nav_order: 2
parent: Sidecar Assets
---

## Sidecar directory

As an alternative, views and other assets can be placed in a sidecar directory with the same name as the component, which can be useful for organizing views alongside other assets like Javascript and CSS.

```text
app/components
├── ...
├── example_component.rb
├── example_component
|   ├── example_component.css
|   ├── example_component.html.erb
|   └── example_component.js
├── ...
```

To generate a component with a sidecar directory, use the `--sidecar` flag:

```text
bin/rails generate component Example title content --sidecar
      invoke  test_unit
      create  test/components/example_component_test.rb
      create  app/components/example_component.rb
      create  app/components/example_component/example_component.html.erb
```

## Component file inside Sidecar directory

It's also possible to place the Ruby component file inside the sidecar directory, grouping all related files in the same folder:

_Note: Avoid giving your containing folder the same name as your `.rb` file or there will be a conflict between Module and Class definitions_

```text
app/components
├── ...
├── example
|   ├── component.rb
|   ├── component.css
|   ├── component.html.erb
|   └── component.js
├── ...
```

The component can then be rendered using the folder name as a namespace:

```text
<%= render(Example::Component.new(title: "my title")) do %>
  Hello, World!
<% end %>
```
