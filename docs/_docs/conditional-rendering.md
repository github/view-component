---
layout: default
title: Conditional Rendering
nav_order: 11
---

## Conditional Rendering

Components can implement a `#render?` method to be called after initialization to determine if the component should render.

Traditionally, the logic for whether to render a view could go in either the component template:

`app/components/confirm_email_component.html.erb`

```text
<% if user.requires_confirmation? %>
  <div class="alert">Please confirm your email address.</div>
<% end %>
```

or the view that renders the component:

`app/views/_banners.html.erb`

```text
<% if current_user.requires_confirmation? %>
  <%= render(ConfirmEmailComponent.new(user: current_user)) %>
<% end %>
```

Using the `#render?` hook simplifies the view:

`app/components/confirm_email_component.rb`

```ruby
class ConfirmEmailComponent < ViewComponent::Base
  def initialize(user:)
    @user = user
  end

  def render?
    @user.requires_confirmation?
  end
end
```

`app/components/confirm_email_component.html.erb`

```text
<div class="banner">
  Please confirm your email address.
</div>
```

`app/views/_banners.html.erb`

```text
<%= render(ConfirmEmailComponent.new(user: current_user)) %>
```

_To assert that a component has not been rendered, use `refute_component_rendered` from `ViewComponent::TestHelpers`._
