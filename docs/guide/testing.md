---
layout: default
title: Testing
parent: Guide
---

# Testing

Unit test components using the `render_inline` test helper, asserting against the rendered output:

```ruby
require "test_helper"

class ExampleComponentTest < ViewComponent::TestCase
  def test_render_component
    render_inline(ExampleComponent.new(title: "my title")) { "Hello, World!" }

    assert_selector("span[title='my title']", text: "Hello, World!")
    # or, to just assert against the text:
    assert_text("Hello, World!")
  end
end
```

(Capybara matchers are available if the gem is installed)

_Note: `assert_selector` only matches on visible elements by default. To match on hidden elements, add `visible: false`. See the [Capybara documentation](https://rubydoc.info/github/jnicklas/capybara/Capybara/Node/Matchers) for more details._

## Antipatterns

Avoid testing ViewComponent instance methods directly. Test the rendered output to ensure the correct behavior for the consumer of the ViewComponent:

```ruby
# Good
assert_selector(".Label", text: "My label")

# Bad
assert_equal MyComponent.new.label, "My label"
```

## Without `capybara`

In the absence of `capybara`, assert against the return value of `render_inline`, which is an instance of `Nokogiri::HTML::DocumentFragment`:

```ruby
def test_render_component
  result = render_inline(ExampleComponent.new(title: "my title")) { "Hello, World!" }

  assert_includes result.css("span[title='my title']").to_html, "Hello, World!"
end
```

Alternatively, assert against the raw output of the component, which is exposed as `rendered_component`:

```ruby
def test_render_component
  render_inline(ExampleComponent.new(title: "my title")) { "Hello, World!" }

  assert_includes rendered_component, "Hello, World!"
end
```

## Slots

To test components that use Slots:

```ruby
def test_renders_slots_with_content
  render_inline(SlotsComponent.new(footer: "Bye!")) do |component|
    component.title { "Hello!" }
    component.body { "Have a nice day." }
  end

  assert_selector(".title", text: "Hello!")
  assert_selector(".body", text: "Have a nice day.")
end
```

## Action Pack Variants

Use the `with_variant` helper to test specific variants:

```ruby
def test_render_component_for_tablet
  with_variant :tablet do
    render_inline(ExampleComponent.new(title: "my title")) { "Hello, tablets!" }

    assert_selector("span[title='my title']", text: "Hello, tablets!")
  end
end
```

## Configuring the controller used in tests

Component tests assume the existence of an `ApplicationController` class, which can be configured globally using the `test_controller` option:

```ruby
config.view_component.test_controller = "BaseController"
```

To configure the controller used for a test case, use `with_controller_class` from `ViewComponent::TestHelpers`.

```ruby
class ExampleComponentTest < ViewComponent::TestCase
  def test_component_in_public_controller
    with_controller_class PublicController do
      render_inline ExampleComponent.new

      assert_text "foo"
    end
  end

  def test_component_in_authenticated_controller
    with_controller_class AuthenticatedController do
      render_inline ExampleComponent.new

      assert_text "bar"
    end
  end
end
```

## Setting `request.path_parameters`

Some Rails helpers won't work unless `request.path_parameters` are set correctly, resulting in an `ActionController::UrlGenerationError`.

To set `request.path_parameters` for a test case, use `with_request_url` from `ViewComponent::TestHelpers`:

```ruby
class ExampleComponentTest < ViewComponent::TestCase
  def test_with_request_url
    with_request_url "/products/42" do
      render_inline ExampleComponent.new # contains i.e. `link_to "French", url_for(locale: "fr")`
      assert_link "French", href: "/products/42?locale=fr"
    end
  end
end
```

## RSpec configuration

To use RSpec, add the following:

```ruby
# spec/rails_helper.rb
require "view_component/test_helpers"
require "capybara/rspec"

RSpec.configure do |config|
  config.include ViewComponent::TestHelpers, type: :component
  config.include Capybara::RSpecMatchers, type: :component
end
```

Specs created by the generator have access to test helpers like `render_inline`. For example:

```ruby
require "rails_helper"

RSpec.describe ExampleComponent, type: :component do
  it "renders component" do
    render_inline(described_class.new(title: "my title")) { "Hello, World!" }

    expect(rendered_component).to have_css "span[title='my title']", text: "Hello, World!"
    # or, to just assert against the text
    expect(rendered_component).to have_text "Hello, World!"
  end
end
```

To use component previews:

```ruby
# config/application.rb
config.view_component.preview_paths << "#{Rails.root}/spec/components/previews"
```
