---
layout: default
title: Using helpers
nav_order: 14
---

## Using helpers

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
