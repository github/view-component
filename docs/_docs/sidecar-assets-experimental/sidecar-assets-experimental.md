---
layout: default
title: Sidecar assets (experimental)
nav_order: 19
has_children: true
permalink: /docs/sidecar-assets-experimental
---

## Sidecar assets (experimental)

It’s possible to include Javascript and CSS alongside components, sometimes called "sidecar" assets or files.

To use the Webpacker gem to compile sidecar assets located in `app/components`:

1. In `config/webpacker.yml`, add `"app/components"` to the `resolved_paths` array \(e.g. `resolved_paths: ["app/components"]`\).
2. In the Webpack entry file \(often `app/javascript/packs/application.js`\), add an import statement to a helper file, and in the helper file, import the components' Javascript:

```javascript
import "../components"
```

Then, in `app/javascript/components.js`, add:

```javascript
function importAll(r) {
  r.keys().forEach(r)
}

importAll(require.context("../components", true, /_component.js$/))
```

Any file with the `_component.js` suffix \(such as `app/components/widget_component.js`\) will be compiled into the Webpack bundle. If that file itself imports another file, for example `app/components/widget_component.css`, it will also be compiled and bundled into Webpack's output stylesheet if Webpack is being used for styles.
