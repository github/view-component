---
layout: default
title: Quick start
nav_order: 4
---

## Quick start

Use the component generator to create a new ViewComponent.

The generator accepts a component name and a list of arguments:

```bash
bin/rails generate component Example title content
      invoke  test_unit
      create  test/components/example_component_test.rb
      create  app/components/example_component.rb
      create  app/components/example_component.html.erb
```

ViewComponent includes template generators for the `erb`, `haml`, and `slim` template engines and will default to the template engine specified in `config.generators.template_engine`.

The template engine can also be passed as an option to the generator:

```bash
bin/rails generate component Example title content --template-engine slim
```
