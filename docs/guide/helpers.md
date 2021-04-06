---
layout: default
title: Helpers
parent: Building ViewComponents
---

# Helpers

Helper methods can be used through the `helpers` proxy:

```ruby
module IconHelper
  def icon(name)
    tag.i data: { feather: name.to_s.dasherize }
  end
end

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

Helpers can also be used by including the helper:

```ruby
class UserComponent < ViewComponent::Base
  include IconHelper

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
