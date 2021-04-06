---
layout: default
title: Stimulus
nav_order: 20
---

## Stimulus

In Stimulus, create a 1:1 mapping between a Stimulus controller and a component. In order to load in Stimulus controllers from the `app/components` tree, amend the Stimulus boot code in `app/javascript/packs/application.js`:

```javascript
const application = Application.start()
const context = require.context("controllers", true, /.js$/)
const context_components = require.context("../../components", true, /_controller.js$/)
application.load(
  definitionsFromContext(context).concat(
    definitionsFromContext(context_components)
  )
)
```

This enables the creation of files such as `app/components/widget_controller.js`, where the controller identifier matches the `data-controller` attribute in the component's HTML template.

After configuring Webpack to load Stimulus controller files from the `components` directory, add the path to `resolved_paths` in `config/webpacker.yml`:

```text
  resolved_paths: ["app/components"]
```

When placing a Stimulus controller inside a sidecar directory, be aware that when referencing the controller [each forward slash in a namespaced controller file’s path becomes two dashes in its identifier](https://stimulusjs.org/handbook/installing#controller-filenames-map-to-identifiers):

```text
app/components
├── ...
├── example
|   ├── component.rb
|   ├── component.css
|   ├── component.html.erb
|   └── component_controller.js
├── ...
```

`component_controller.js`'s Stimulus identifier becomes: `example--component`:

```text
<div data-controller="example--component">
  <input type="text">
  <button data-action="click->example--component#greet">Greet</button>
</div>
```
