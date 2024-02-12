---
layout: default
title: Helpers
parent: How-to guide
---

# Helpers

Helpers must be included to be used:

```ruby
module IconHelper
  def icon(name)
    tag.i data: {feather: name.to_s}
  end
end

class UserComponent < ViewComponent::Base
  include IconHelper

  def profile_icon
    icon :user
  end
end
```

## Proxy

Since 1.5.0
{: .label }

Or, access helpers through the `helpers` proxy:

```ruby
class UserComponent < ViewComponent::Base
  def profile_icon
    helpers.icon :user
  end
end
```

Which can be used with `delegate`:

```ruby
class UserComponent < ViewComponent::Base
  delegate :icon, to: :helpers

  def profile_icon
    icon :user
  end
end
```

## UseHelpers setter

By default, ViewComponents don't have access to helper methods defined externally. The `use_helpers` method allows external helpers to be called from the component.

`use_helpers` defines the helper on the component, similar to `delegate`:

```ruby
class UseHelpersComponent < ViewComponent::Base
  use_helpers :icon, :icon?

  erb_template <<-ERB
    <div class="icon">
      <%= icon? ? icon(:user) : icon(:guest) %>
    </div>
  ERB
end
```

Use the `from:` keyword to include individual methods defined in helper modules not available in the component:

```ruby
class UserComponent < ViewComponent::Base
  use_helpers :icon, :icon?, from: IconHelper

  def profile_icon
    icon? ? icon(:user) : icon(:guest)
  end
end
```

Use the `prefix:` keyword to prefix the helper method with the name of the helper module:

```ruby
class UserComponent < ViewComponent::Base
  use_helpers :icon, :icon?, from: IconHelper, prefix: true

  def profile_icon
    icon_helper_icon? ? icon_helper_icon(:user) : icon_helper_icon(:guest)
  end
end
```

or use the `prefix:` keyword with a custom prefix:

```ruby
class UserComponent < ViewComponent::Base
  use_helpers :icon, :icon?, from: IconHelper, prefix: :user

  def profile_icon
    user_icon? ? user_icon(:user) : user_icon(:guest)
  end
end
```

The singular version `use_helper` is also available:

```ruby
class UserComponent < ViewComponent::Base
  use_helper :icon, from: IconHelper

  def profile_icon
    icon :user
  end
end
```

## Nested URL helpers

Rails nested URL helpers implicitly depend on the current `request` in certain cases. Since ViewComponent is built to enable reusing components in different contexts, nested URL helpers should be passed their options explicitly:

```ruby
# bad
edit_user_path # implicitly depends on current request to provide `user`

# good
edit_user_path(user: current_user)
```
