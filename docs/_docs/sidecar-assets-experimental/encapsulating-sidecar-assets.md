---
layout: default
title: Encapsulating sidecar assets
nav_order: 2
parent: Sidecar assets (experimental)
---

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

```text
<my-comment comment-id="<%= comment.id %>">
  <time slot="posted" datetime="<%= comment.created_at.iso8601 %>"><%= comment.created_at.strftime("%b %-d") %></time>

  <div slot="avatar"><img src="<%= avatar %>" /></div>

  <div slot="author"><%= commenter_name %></div>

  <div slot="body"><%= formatted_body %></div>
</my-comment>
```

`app/components/comment_component.js`

```javascript
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
