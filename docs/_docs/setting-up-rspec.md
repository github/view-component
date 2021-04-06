---
layout: default
title: Setting up RSpec
nav_order: 17
---

## Setting up RSpec

To use RSpec, add the following:

`spec/rails_helper.rb`

```ruby
require "view_component/test_helpers"

RSpec.configure do |config|
  config.include ViewComponent::TestHelpers, type: :component
end
```

Specs created by the generator have access to test helpers like `render_inline`.

To use component previews:

`config/application.rb`

```ruby
config.view_component.preview_paths << "#{Rails.root}/spec/components/previews"
```
