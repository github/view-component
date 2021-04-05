---
layout: default
title: Slots
parent: Building ViewComponents
---

# Slots

In addition to the `content` accessor, ViewComponents accept content through Slots, enabling multiple blocks of content to be passed to a single ViewComponent.

Slots are defined with `renders_one` and `renders_many`:

`renders_one` defines a slot that will be rendered at most once per component: `renders_one :header`

`renders_many` defines a slot that can be rendered multiple times per-component: `renders_many :blog_posts`

_To view documentation for content_areas (deprecated) and the original implementation of Slots (soon to be deprecated), see [/content_areas](/content_areas) and [/slots_v1](/slots_v1)._

## Defining slots

**Note**: In versions `< 2.28.0`, `include ViewComponent::SlotableV2` to use slots.

Slots come in three forms:

- [Delegate slots](#delegate-slots) render other components.
- [Lambda slots](#lambda-slots) render strings or initialized components.
- [Pass through slots](#pass-through-slots)  pass content directly to another component.

## Delegate slots

Delegate slots delegate to another component:

`# blog_component.rb`

```ruby
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

`# blog_component.html.erb`

```erb
<div>
  <%= header %> <!-- render the header component -->

  <% posts.each do |post| %>
    <div class="blog-post-wrapper">
      <%= post %> <!-- render an individual post -->
    </div>
  <% end %>
</div>
```

`# index.html.erb`

```erb
<%= render BlogComponent.new do |c| %>
  <% c.header(classes: "") do %>
    <%= link_to "My Site", root_path %>
  <% end %>

  <%= c.post(title: "My blog post") do %>
    Really interesting stuff.
  <% end %>

  <%= c.post(title: "Another post!") do %>
    Blog every day.
  <% end %>
<% end %>
```

## Lambda Slots

Lambda slots render their return value. Lambda slots are useful for working with helpers like `content_tag` or as wrappers for another component with specific default values.

```ruby
class BlogComponent < ViewComponent::Base
  # Renders the returned string
  renders_one :header, -> (classes:) do
    content_tag :h1 do
      link_to title, root_path, { class: classes }
    end
  end

  # Returns a component that will be rendered in that slot with a default argument.
  renders_many :posts, -> (title:, classes:) do
    PostComponent.new(title: title, classes: "my-default-class " + classes)
  end
end
```

Lambda are able to access state from the parent component:

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

## Pass through slots

Pass through slots capture content passed with a block.

Define a pass through slot by omitting the second argument to `renders_one` and `renders_many`:

```ruby
# blog_component.rb
class BlogComponent < ViewComponent::Base
  renders_one :header
  renders_many :posts
end
```

`# blog_component.html.erb`

```erb
<div>
  <h1><%= header %></h1>

  <% posts.each do |post| %>
    <%= post %>
  <% end %>
</div>
```

`# index.html.erb`

```erb
<div>
  <%= render BlogComponent.new do |c| %>
    <%= c.header(classes: '') do %>
      <%= link_to "My blog", root_path %>
    <% end %>

    <% @posts.each do |post| %>
      <%= c.post(post: post) %>
    <% end %>
  <% end %>
</div>
```

## Rendering Collections

Collection slots (declared with `renders_many`) can also be passed a collection.

e.g.

`# navigation_component.rb`

```ruby
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

`# navigation_component.html.erb`

```erb
<div>
  <% links.each do |link| %>
    <%= link %>
  <% end %>
</div>
```

`# index.html.erb`

```erb
<%= render(NavigationComponent.new) do |c| %>
  <%= c.links([
    { name: "Home", href: "/" },
    { name: "Pricing", href: "/pricing" },
    { name: "Sign Up", href: "/sign-up" },
  ]) %>
<% end %>
```
