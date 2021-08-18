---
layout: default
title: Creating a Gem
---

# Creating a Gem

Start by creating a new Rails engine with the following arguments:

```sh
rails plugin new shared-view_components \
  --full \
  --skip-namespace \
  --skip-action-mailer \
  --skip-action-mailbox \
  --skip-action-text \
  --skip-active-record \
  --skip-active-job \
  --skip-active-storage \
  --skip-action-cable \
  --skip-turbolinks \
  --skip-jbuilder \
  --skip-gemfile-entry # only use this when adding a gem into an existing Rails app
```

Update the gemspec. Add the dependency:

```ruby
spec.add_dependency "view_component", ">= 2.32"
```

Afterwards, add the require command into `shared/view_components.rb`:

```ruby
require "view_component/engine"
```

Let's create our first component:

```sh
✗ bin/rails g component Shared::Example title --skip-namespace
      create  app/components/shared/example_component.rb
      invoke  test_unit
      create    test/components/shared/example_component_test.rb
      invoke  erb
      create    app/components/shared/example_component.html.erb
```

Update `example_component.html.erb` to the following:

```erb
<span title="<%= @title %>"><%= content %></span>
```

Now, let't write a test for the component. Open `test/components/example_component_test.rb`

```ruby
require "test_helper"

class ExampleComponentTest < ViewComponent::TestCase
  def test_renders
    assert_equal(
      %(<span title="Hello">World!</span>),
      render_inline(Shared::ExampleComponent.new(title: "Hello").with_content("World!")).css("span").to_html
    )
  end
end
```

Run the test:

```sh
✗ bin/rails test
Run options: --seed 33407

# Running:

..

Finished in 0.047348s, 42.2404 runs/s, 42.2404 assertions/s.
2 runs, 2 assertions, 0 failures, 0 errors, 0 skips
```

Great! Now lets add test the gem in the dummy test app. To start, we need to add `require "view_component/test_helpers"` to `test_helper.rb`

```ruby
# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require_relative "../test/dummy/config/environment"
require "rails/test_help"

require "view_component/test_helpers"
```

Now create a controller where we can test the component:

```sh
cd test/dummy
bin/rails g controller examples index
      create  app/controllers/examples_controller.rb
       route  get 'examples/index'
      invoke  erb
      create    app/views/examples
      create    app/views/examples/index.html.erb
      invoke  test_unit
      create    test/controllers/examples_controller_test.rb
      invoke  helper
      create    app/helpers/examples_helper.rb
      invoke    test_unit
      invoke  assets
      invoke    css
      create      app/assets/stylesheets/examples.css
```

Now let's add the Shared::ExampleComponent to `test/dummy/app/views/examples/index.html.erb`:

```erb
<%= render(Shared::ExampleComponent.new(title: "Hello")) { "World!" } %>
```

Now let's add a test to `navigation_test.rb` to ensure the component is rendering properly:

```ruby
require "test_helper"

class NavigationTest < ActionDispatch::IntegrationTest
  test "Shared::ExampleComponent renders correctly" do
    get "/examples/index"
    assert_equal 200, status
    assert response.parsed_body.include?('<span title="Hello">World!</span>')
  end
end
```

Finally, run `rails/test` again to ensure it's working properly.

```sh
➜  shared-view_components git:(main) ✗ bin/rails test
Run options: --seed 44611

# Running:

...

Finished in 0.103836s, 28.8917 runs/s, 38.5223 assertions/s.
3 runs, 4 assertions, 0 failures, 0 errors, 0 skips
```
