---
layout: default
title: Slots
parent: Building ViewComponents
---

# Slots

In addition to the `content` accessor, ViewComponents can accept content through slots. Think of slots as a way to render multiple blocks of content, including other components.

Slots are defined with `renders_one` and `renders_many`:

- `renders_one` defines a slot that will be rendered at most once per component: `renders_one :header`
- `renders_many` defines a slot that can be rendered multiple times per-component: `renders_many :posts`

If you don't specify a second argument to these methods, you'll create a **passthrough slot**. Arbitrary content can be
rendered inside these slots. If you need to render arbitrary markup or components, these may be the way to go.

For example:

```ruby
# blog_component.rb
class BlogComponent < ViewComponent::Base
  renders_one :header
  renders_many :posts
end
```

To render a `renders_one` slot, call the name of the slot.

To render a `renders_many` slot, iterate over the name of the slot:

```erb
<%# blog_component.html.erb %>
<h1><%= header %></h1>

<% posts.each do |post| %>
  <%= post %>
<% end %>
```

```erb
<%# index.html.erb %>
<%= render BlogComponent.new do |c| %>
  <% c.header do %>
    <%= link_to "My blog", root_path %>
  <% end %>

  <% BlogPost.all.each do |blog_post| %>
    <%= c.post do %>
      <%= link_to blog_post.name, blog_post.url %>
    <% end %>
  <% end %>
<% end %>
```

The link to "My blog" will render inside the `<h1>` tags, and links to each `BlogPost` will be rendered beneath.

## Component slots

Slots can also render other components. Pass the name of the component as the second argument. Component slots are
useful when you want to render a specific component, but still allow full control of the arguments that are passed to
it.

```ruby
# blog_component.rb
class BlogComponent < ViewComponent::Base
  # Since `HeaderComponent` is nested inside of this component, we have to
  # reference it as a string instead of a class name.
  renders_one :header, "HeaderComponent"

  # `PostComponent` is defined in another file, so we can refer to it by class name.
  renders_many :posts, PostComponent

  class HeaderComponent < ViewComponent::Base
    attr_reader :classes

    def initialize(classes:)
      @classes = classes
    end

    def call
      content_tag :h1, content, { class: classes }
    end
  end
end
```

```erb
<%# blog_component.html.erb %>
<%= header %>

<% posts.each do |post| %>
  <%= post %>
<% end %>
```

```erb
<%# index.html.erb %>
<%= render BlogComponent.new do |c| %>
  <% c.header(classes: "") do %>
    <%= link_to "My Site", root_path %>
  <% end %>

  <% c.post(title: "My blog post") do %>
    Really interesting stuff.
  <% end %>

  <% c.post(title: "Another post!") do %>
    Blog every day.
  <% end %>
<% end %>
```

## Lambda slots

It's also possible to define a slot as a lambda that returns content to be rendered (either a string or a ViewComponent instance). Lambda slots are useful in cases where writing another component may be unnecessary, such as working with helpers like `content_tag` or as wrappers for another ViewComponent with specific default values:

```ruby
class BlogComponent < ViewComponent::Base
  renders_one :header, -> (classes:) do
    # This isn't complex enough to be its own component yet, so we'll use a
    # lambda slot. If it gets much bigger, it should be extracted out to a
    # ViewComponent and rendered here with a component slot.
    content_tag :h1 do
      link_to title, root_path, { class: classes }
    end
  end

  # It's also possible to return another ViewComponent with preset default values:
  renders_many :posts, -> (title:, classes:) do
    PostComponent.new(title: title, classes: "my-default-class " + classes)
  end
end
```

Lambda slots are able to access state from the parent ViewComponent:

```ruby
class TableComponent < ViewComponent::Base
  renders_one :header, -> do
    HeaderComponent.new(selectable: @selectable)
  end

  def initialize(selectable: false)
    @selectable = selectable
  end
end
```

## Rendering collections

`renders_many` slots can also be passed a collection, using the plural setter (`links` in this example):

```ruby
# navigation_component.rb
class NavigationComponent < ViewComponent::Base
  renders_many :links, "LinkComponent"

  class LinkComponent < ViewComponent::Base
    def initialize(name:, href:)
      @name = name
      @href = href
    end
  end
end
```

```erb
<%# navigation_component.html.erb %>
<% links.each do |link| %>
  <%= link %>
<% end %>
```

```erb
<%# index.html.erb %>
<%= render(NavigationComponent.new) do |c| %>
  <% c.links([
    { name: "Home", href: "/" },
    { name: "Pricing", href: "/pricing" },
    { name: "Sign Up", href: "/sign-up" },
  ]) %>
<% end %>
```

## `#with_content`

Slot content can also be set using `#with_content`:

```erb
<%= render BlogComponent.new do |c| %>
  <% c.header(classes: "title").with_content("My blog") %>
<% end %>
```

_To view documentation for content_areas (deprecated) and the original implementation of Slots (deprecated), see [/content_areas](/content_areas) and [/slots_v1](/slots_v1)._
