---
layout: default
title: Sidecar assets
parent: Building ViewComponents
---

# Sidecar assets (experimental)

It’s possible to include Javascript and CSS alongside components, sometimes called "sidecar" assets or files.

To use the Webpacker gem to compile sidecar assets located in `app/components`:

1. In `config/webpacker.yml`, add `"app/components"` to the `resolved_paths` array (e.g. `resolved_paths: ["app/components"]`).
2. In the Webpack entry file (often `app/javascript/packs/application.js`), add an import statement to a helper file, and in the helper file, import the components' Javascript:

```js
import "../components"
```

Then, in `app/javascript/components.js`, add:

```js
function importAll(r) {
  r.keys().forEach(r)
}

importAll(require.context("../components", true, /[_\/]component\.js$/))
```

Any file with the `_component.js` suffix (such as `app/components/widget_component.js`) will be compiled into the Webpack bundle. If that file itself imports another file, for example `app/components/widget_component.css`, it will also be compiled and bundled into Webpack's output stylesheet if Webpack is being used for styles.

## Encapsulating sidecar assets

Ideally, sidecar Javascript/CSS should not "leak" out of the context of its associated component.

One approach is to use Web Components, which contain all Javascript functionality, internal markup, and styles within the shadow root of the Web Component.

For example:

`app/components/comment_component.rb`

```ruby
class CommentComponent < ViewComponent::Base
  def initialize(comment:)
    @comment = comment
  end

  def commenter
    @comment.user
  end

  def commenter_name
    commenter.name
  end

  def avatar
    commenter.avatar_image_url
  end

  def formatted_body
    simple_format(@comment.body)
  end

  private

  attr_reader :comment
end
```

`app/components/comment_component.html.erb`

```erb
<my-comment comment-id="<%= comment.id %>">
  <time slot="posted" datetime="<%= comment.created_at.iso8601 %>"><%= comment.created_at.strftime("%b %-d") %></time>

  <div slot="avatar"><img src="<%= avatar %>" /></div>

  <div slot="author"><%= commenter_name %></div>

  <div slot="body"><%= formatted_body %></div>
</my-comment>
```

`app/components/comment_component.js`

```js
class Comment extends HTMLElement {
  styles() {
    return `
      :host {
        display: block;
      }
      ::slotted(time) {
        float: right;
        font-size: 0.75em;
      }
      .commenter { font-weight: bold; }
      .body { … }
    `
  }

  constructor() {
    super()
    const shadow = this.attachShadow({mode: 'open'});
    shadow.innerHTML = `
      <style>
        ${this.styles()}
      </style>
      <slot name="posted"></slot>
      <div class="commenter">
        <slot name="avatar"></slot> <slot name="author"></slot>
      </div>
      <div class="body">
        <slot name="body"></slot>
      </div>
    `
  }
}
customElements.define('my-comment', Comment)
```

## Stimulus

In Stimulus, create a 1:1 mapping between a Stimulus controller and a component. In order to load in Stimulus controllers from the `app/components` tree, amend the Stimulus boot code in `app/javascript/packs/application.js`:

```js
const application = Application.start()
const context = require.context("controllers", true, /\.js$/)
const contextComponents = require.context("../../components", true, /_controller\.js$/)
application.load(
  definitionsFromContext(context).concat(
    definitionsFromContext(contextComponents)
  )
)
```

This enables the creation of files such as `app/components/widget_controller.js`, where the controller identifier matches the `data-controller` attribute in the component's HTML template.

After configuring Webpack to load Stimulus controller files from the `components` directory, add the path to `resolved_paths` in `config/webpacker.yml`:

```yml
  resolved_paths: ["app/components"]
```

When placing a Stimulus controller inside a sidecar directory, be aware that when referencing the controller [each forward slash in a namespaced controller file’s path becomes two dashes in its identifier](
https://stimulusjs.org/handbook/installing#controller-filenames-map-to-identifiers):

```console
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

```erb
<div data-controller="example--component">
  <input type="text">
  <button data-action="click->example--component#greet">Greet</button>
</div>
```
