A framework for building reusable, testable & encapsulated view components in Ruby on Rails.

[View on GitHub →](https://github.com/github/view_component)

## Design philosophy

ViewComponent is designed to integrate as seamlessly as possible [with Rails](https://rubyonrails.org/doctrine/), with the [least surprise](https://www.artima.com/intv/ruby4.html).

## Compatibility

ViewComponent is [supported natively](https://edgeguides.rubyonrails.org/layouts_and_rendering.html#rendering-objects) in Rails 6.1, and compatible with Rails 5.0+ via an included [monkey patch](https://github.com/github/view_component/blob/main/lib/view_component/render_monkey_patch.rb).

ViewComponent is tested for compatibility [with combinations of](https://github.com/github/view_component/blob/22e3d4ccce70d8f32c7375e5a5ccc3f70b22a703/.github/workflows/ruby_on_rails.yml#L10-L11) Ruby 2.4+ and Rails 5+.

## Installation

In `Gemfile`, add:

```ruby
gem "view_component", require: "view_component/engine"
```

## Guide

### What are components?

ViewComponents are Ruby objects that output HTML. Think of them as an evolution of the presenter pattern, inspired by [React](https://reactjs.org/docs/react-component.html).

### When should I use components?

Components are most effective in cases where view code is reused or benefits from being tested directly. Heavily reused partials and templates with significant amounts of embedded Ruby often make good ViewComponents.

### Why should I use components?

#### Testing

Unlike traditional Rails views, ViewComponents can be unit-tested. In the GitHub codebase, component unit tests take around 25 milliseconds each, compared to about six seconds for controller tests.

Rails views are typically tested with slow integration tests that also exercise the routing and controller layers in addition to the view. This cost often discourages thorough test coverage.

With ViewComponent, integration tests can be reserved for end-to-end assertions, with permutations and corner cases covered at the unit level.

#### Data Flow

Traditional Rails views have an implicit interface, making it hard to reason about what information is needed to render, leading to subtle bugs when rendering the same view in different contexts.

ViewComponents use a standard Ruby initializer that clearly defines what is needed to render, making them easier (and safer) to reuse than partials.

#### Performance

Based on our [benchmarks](https://github.com/github/view_component/blob/main/performance/benchmark.rb), ViewComponents are ~10x faster than partials.

#### Standards

Views often fail basic Ruby code quality standards: long methods, deep conditional nesting, and mystery guests abound.

ViewComponents are Ruby objects, making it easy to follow (and enforce) code quality standards.

### Building components

#### Conventions

Components are subclasses of `ViewComponent::Base` and live in `app/components`. It's common practice to create and inherit from an `ApplicationComponent` that is a subclass of `ViewComponent::Base`.

Component names end in -`Component`.

Component module names are plural, as for controllers and jobs: `Users::AvatarComponent`

Name components for what they render, not what they accept. (`AvatarComponent` instead of `UserComponent`)

#### Quick start

Use the component generator to create a new ViewComponent.

The generator accepts a component name and a list of arguments:

```bash
bin/rails generate component Example title

      invoke  test_unit
      create  test/components/example_component_test.rb
      create  app/components/example_component.rb
      create  app/components/example_component.html.erb
```

ViewComponent includes template generators for the `erb`, `haml`, and `slim` template engines and will default to the template engine specified in `config.generators.template_engine`.

The template engine can also be passed as an option to the generator:

```bash
bin/rails generate component Example title --template-engine slim
```

To generate a [preview](#previewing-components), pass the `--preview` option:

```bash
bin/rails generate component Example title --preview
```

#### Implementation

A ViewComponent is a Ruby file and corresponding template file with the same base name:

`app/components/example_component.rb`:

```ruby
class ExampleComponent < ViewComponent::Base
  def initialize(title:)
    @title = title
  end
end
```

`app/components/example_component.html.erb`:

```erb
<span title="<%= @title %>"><%= content %></span>
```

Rendered in a view as:

```erb
<%= render(ExampleComponent.new(title: "my title")) do %>
  Hello, World!
<% end %>
```

Returning:

```html
<span title="my title">Hello, World!</span>
```

#### Passing content to ViewComponents

Content passed to a ViewComponent as a block is captured and assigned to the `content` accessor.

ViewComponents also accept content through Slots, enabling multiple blocks of content to be passed to a single ViewComponent.

Slots are defined with `renders_one` and `renders_many`:

`renders_one` defines a slot that will be rendered at most once per component: `renders_one :header`

`renders_many` defines a slot that can be rendered multiple times per-component: `renders_many :blog_posts`

_To view documentation for content_areas (soon to be deprecated) and the original implementation of Slots, see [/content_areas](/content_areas) and [/slots_v1](/slots_v1)._

##### Defining slots

Slots come in three forms:

- [Delegate slots](#delegate-slots) render other components.
- [Lambda slots](#lambda-slots) render strings or initialized components.
- [Pass through slots](#pass-through-slots)  pass content directly to another component.

##### Delegate slots

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

##### Lambda Slots

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

##### Pass through slots

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

  <%= posts %>
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

##### Rendering Collections

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

### Inline Component

ViewComponents can render without a template file, by defining a `call` method:

`app/components/inline_component.rb`:

```ruby
class InlineComponent < ViewComponent::Base
  def call
    if active?
      link_to "Cancel integration", integration_path, method: :delete
    else
      link_to "Integrate now!", integration_path
    end
  end
end
```

It is also possible to define methods for variants:

```ruby
class InlineVariantComponent < ViewComponent::Base
  def call_phone
    link_to "Phone", phone_path
  end

  def call
    link_to "Default", default_path
  end
end
```

And render them `with_variant`:

```erb
<%= render InlineVariantComponent.new.with_variant(:phone) %>

# output: <%= link_to "Phone", phone_path %>
```

_**Note**: `call_*` methods must be public._

### Validations

ViewComponent does not include support for validations. However, it can be added by using `ActiveModel::Validations`:

```ruby
class ExampleComponent < ViewComponent::Base
  include ActiveModel::Validations

  # Requires that a content block be passed to the component
  validate :content, presence: true

  def before_render
    validate!
  end
end
```

_Note: Using validations in this manner can lead to runtime exceptions. Use them wisely._

### Template Inheritance

Components that subclass another component inherit the parent component's
template if they don't define their own template.

```ruby
# If `my_link_component.html.erb` is not defined the component will fall back
# to `LinkComponent`s template
class MyLinkComponent < LinkComponent
end
```

### Sidecar Assets

ViewComponents supports two options for defining view files.

#### Sidecar view

The simplest option is to place the view next to the Ruby component:

```console
app/components
├── ...
├── example_component.rb
├── example_component.html.erb
├── ...
```

#### Sidecar directory

As an alternative, views and other assets can be placed in a sidecar directory with the same name as the component, which can be useful for organizing views alongside other assets like Javascript.

```console
app/components
├── ...
├── example_component.rb
├── example_component
|   ├── example_component.html.erb
|   └── example_component.js
├── ...
```

To generate a component with a sidecar directory, use the `--sidecar` flag:

```console
bin/rails generate component Example title --sidecar
      invoke  test_unit
      create  test/components/example_component_test.rb
      create  app/components/example_component.rb
      create  app/components/example_component/example_component.html.erb
```

#### Component file inside Sidecar directory

It's also possible to place the Ruby component file inside the sidecar directory, grouping all related files in the same folder:

_Note: Avoid giving your containing folder the same name as your `.rb` file or there will be a conflict between Module and Class definitions_

```console
app/components
├── ...
├── example
|   ├── component.rb
|   ├── component.css
|   ├── component.html.erb
|   └── component.js
├── ...

```

The component can then be rendered using the folder name as a namespace:

```erb
<%= render(Example::Component.new(title: "my title")) do %>
  Hello, World!
<% end %>
```

### Conditional Rendering

Components can implement a `#render?` method to be called after initialization to determine if the component should render.

Traditionally, the logic for whether to render a view could go in either the component template:

`app/components/confirm_email_component.html.erb`

```erb
<% if user.requires_confirmation? %>
  <div class="alert">Please confirm your email address.</div>
<% end %>
```

or the view that renders the component:

`app/views/_banners.html.erb`

```erb
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

```erb
<div class="banner">
  Please confirm your email address.
</div>
```

`app/views/_banners.html.erb`

```erb
<%= render(ConfirmEmailComponent.new(user: current_user)) %>
```

_To assert that a component has not been rendered, use `refute_component_rendered` from `ViewComponent::TestHelpers`._

### `#before_render`

ViewComponents can define a `before_render` method to be called before a component is rendered, when `helpers` is able to be used:

`app/components/example_component.rb`

```ruby
class ExampleComponent < ViewComponent::Base
  def before_render
    @my_icon = helpers.star_icon
  end
end
```

### Rendering collections

Use `with_collection` to render a ViewComponent with a collection:

`app/view/products/index.html.erb`

``` erb
<%= render(ProductComponent.with_collection(@products)) %>
```

`app/components/product_component.rb`

``` ruby
class ProductComponent < ViewComponent::Base
  def initialize(product:)
    @product = product
  end
end
```

[By default](https://github.com/github/view_component/blob/89f8fab4609c1ef2467cf434d283864b3c754473/lib/view_component/base.rb#L249), the component name is used to define the parameter passed into the component from the collection.

#### `with_collection_parameter`

Use `with_collection_parameter` to change the name of the collection parameter:

`app/components/product_component.rb`

``` ruby
class ProductComponent < ViewComponent::Base
  with_collection_parameter :item

  def initialize(item:)
    @item = item
  end
end
```

#### Additional arguments

Additional arguments besides the collection are passed to each component instance:

`app/view/products/index.html.erb`

``` erb
<%= render(ProductComponent.with_collection(@products, notice: "hi")) %>
```

`app/components/product_component.rb`

``` ruby
class ProductComponent < ViewComponent::Base
  with_collection_parameter :item

  def initialize(item:, notice:)
    @item = item
    @notice = notice
  end
end
```

`app/components/product_component.html.erb`

``` erb
<li>
  <h2><%= @item.name %></h2>
  <span><%= @notice %></span>
</li>
```

#### Collection counter

ViewComponent defines a counter variable matching the parameter name above, followed by `_counter`. To access the variable, add it to `initialize` as an argument:

`app/components/product_component.rb`

``` ruby
class ProductComponent < ViewComponent::Base
  def initialize(product:, product_counter:)
    @product = product
    @counter = product_counter
  end
end
```

`app/components/product_component.html.erb`

``` erb
<li>
  <%= @counter %> <%= @product.name %>
</li>
```

### Using helpers

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

#### Using nested URL helpers

Rails nested URL helpers implicitly depend on the current `request` in certain cases. Since ViewComponent is built to enable reusing components in different contexts, nested URL helpers should be passed their options explicitly:

```ruby
# bad
edit_user_path # implicitly depends on current request to provide `user`

# good
edit_user_path(user: current_user)
```

### Writing tests

Unit test components directly, using the `render_inline` test helper, asserting against the rendered output.

Capybara matchers are available if the gem is installed:

```ruby
require "view_component/test_case"

class ExampleComponentTest < ViewComponent::TestCase
  def test_render_component
    render_inline(ExampleComponent.new(title: "my title")) { "Hello, World!" }

    assert_selector("span[title='my title']", text: "Hello, World!")
    # or, to just assert against the text:
    assert_text("Hello, World!")
  end
end
```

_Note: `assert_selector` only matches on visible elements by default. To match on hidden elements, add `visible: false`. See the [Capybara documentation](https://rubydoc.info/github/jnicklas/capybara/Capybara/Node/Matchers) for more details._

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

To test components that use `with_content_areas`:

```ruby
def test_renders_content_areas_template_with_content
  render_inline(ContentAreasComponent.new(footer: "Bye!")) do |component|
    component.with(:title, "Hello!")
    component.with(:body) { "Have a nice day." }
  end

  assert_selector(".title", text: "Hello!")
  assert_selector(".body", text: "Have a nice day.")
  assert_selector(".footer", text: "Bye!")
end
```

#### Action Pack Variants

Use the `with_variant` helper to test specific variants:

```ruby
def test_render_component_for_tablet
  with_variant :tablet do
    render_inline(ExampleComponent.new(title: "my title")) { "Hello, tablets!" }

    assert_selector("span[title='my title']", text: "Hello, tablets!")
  end
end
```

### Previewing Components

`ViewComponent::Preview`, like `ActionMailer::Preview`, provides a quick way to preview components in isolation.

_For a more interactive experience, consider using [ViewComponent::Storybook](https://github.com/jonspalmer/view_component_storybook)._

`ViewComponent::Preview`s are defined as:

`test/components/previews/example_component_preview.rb`

```ruby
class ExampleComponentPreview < ViewComponent::Preview
  def with_default_title
    render(ExampleComponent.new(title: "Example component default"))
  end

  def with_long_title
    render(ExampleComponent.new(title: "This is a really long title to see how the component renders this"))
  end

  def with_content_block
    render(ExampleComponent.new(title: "This component accepts a block of content")) do
      tag.div do
        content_tag(:span, "Hello")
      end
    end
  end
end
```

Which generates <http://localhost:3000/rails/view_components/example_component/with_default_title>,
<http://localhost:3000/rails/view_components/example_component/with_long_title>,
and <http://localhost:3000/rails/view_components/example_component/with_content_block>.

It's also possible to set dynamic values from the params by setting them as arguments:

`test/components/previews/example_component_preview.rb`

```ruby
class ExampleComponentPreview < ViewComponent::Preview
  def with_dynamic_title(title: "Example component default")
    render(ExampleComponent.new(title: title))
  end
end
```

Which enables passing in a value with <http://localhost:3000/rails/view_components/example_component/with_dynamic_title?title=Custom+title>.

The `ViewComponent::Preview` base class includes
[`ActionView::Helpers::TagHelper`](https://api.rubyonrails.org/classes/ActionView/Helpers/TagHelper.html), which provides the [`tag`](https://api.rubyonrails.org/classes/ActionView/Helpers/TagHelper.html#method-i-tag)
and [`content_tag`](https://api.rubyonrails.org/classes/ActionView/Helpers/TagHelper.html#method-i-content_tag) view helper methods.

Previews use the application layout by default, but can use a specific layout with the `layout` option:

`test/components/previews/example_component_preview.rb`

```ruby
class ExampleComponentPreview < ViewComponent::Preview
  layout "admin"

  ...
end
```

You can also set a custom layout to be used by default for previews as well as the preview index pages via the `default_preview_layout` configuration option:

`config/application.rb`

```ruby
# Set the default layout to app/views/layouts/component_preview.html.erb
config.view_component.default_preview_layout = "component_preview"
```

Preview classes live in `test/components/previews`, which can be configured using the `preview_paths` option:

`config/application.rb`

```ruby
config.view_component.preview_paths << "#{Rails.root}/lib/component_previews"
```

Previews are served from <http://localhost:3000/rails/view_components> by default. To use a different endpoint, set the `preview_route` option:

`config/application.rb`

```ruby
config.view_component.preview_route = "/previews"
```

This example will make the previews available from <http://localhost:3000/previews>.

#### Preview templates

Given a preview `test/components/previews/cell_component_preview.rb`, template files can be defined at `test/components/previews/cell_component_preview/`:

`test/components/previews/cell_component_preview.rb`

```ruby
class CellComponentPreview < ViewComponent::Preview
  def default
  end
end
```

`test/components/previews/cell_component_preview/default.html.erb`

```erb
<table class="table">
  <tbody>
    <tr>
      <%= render CellComponent.new %>
    </tr>
  </tbody>
</div>
```

To use a different location for preview templates, pass the `template` argument:
(the path should be relative to `config.view_component.preview_path`):

`test/components/previews/cell_component_preview.rb`

```ruby
class CellComponentPreview < ViewComponent::Preview
  def default
    render_with_template(template: 'custom_cell_component_preview/my_preview_template')
  end
end
```

Values from `params` can be accessed through `locals`:

`test/components/previews/cell_component_preview.rb`

```ruby
class CellComponentPreview < ViewComponent::Preview
  def default(title: "Default title", subtitle: "A subtitle")
    render_with_template(locals: {
      title: title,
      subtitle: subtitle
    })
  end
end
```

Which enables passing in a value with <http://localhost:3000/rails/view_components/cell_component/default?title=Custom+title&subtitle=Another+subtitle>.

#### Configuring preview controller

Previews can be extended to allow users to add authentication, authorization, before actions, or anything that the end user would need to meet their needs using the `preview_controller` option:

`config/application.rb`

```ruby
config.view_component.preview_controller = "MyPreviewController"
```

### Configuring the controller used in tests

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

### Setting up RSpec

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

### Disabling the render monkey patch (Rails < 6.1)

In order to [avoid conflicts](https://github.com/github/view_component/issues/288) between ViewComponent and other gems that also monkey patch the `render` method, it is possible to configure ViewComponent to not include the render monkey patch:

`config.view_component.render_monkey_patch_enabled = false # defaults to true`

With the monkey patch disabled, use `render_component` (or  `render_component_to_string`) instead:

```erb
<%= render_component Component.new(message: "bar") %>
```

### Sidecar CSS (experimental)

_Note: This feature is experimental. Breaking changes should be expected without warning._

ViewComponent includes experimental support for encapsulated sidecar CSS, locally scoping CSS selectors using CSS Modules.

To use the experimental feature, include `ViewComponent::Styleable`:

`app/components/styleable_component.rb`:

```ruby
class StyleableComponent < ViewComponent::Base
  include ViewComponent::Styleable
end
```

Add a sidecar stylesheet for the component:

`app/components/styleable_component.css`:

```css
.foo {
  color: red;
}
```

Use `styles` to retrieve the scoped selector:

`app/components/styleable_component.rb`:

```ruby
class StyleableComponent < ViewComponent::Base
  include ViewComponent::Styleable

  def call
    content_tag(:div, "Hello, World!", class: styles['foo'])
  end
end
```

Render the component in a view:

```erb
<%= render(StyleableComponent.new) %>
```

Returning:

```html
<div class="Css_0343d_foo">Hello, World!</div>
<style>.Css_0343d_foo { color: red; }</style>
```

### Sidecar javascript (experimental)

It’s possible to include Javascript alongside components.

To use the Webpacker gem to compile javascript located in `app/components`:

1. In `config/webpacker.yml`, add `"app/components"` to the `resolved_paths` array (e.g. `resolved_paths: ["app/components"]`).
2. In the Webpack entry file (often `app/javascript/packs/application.js`), add an import statement to a helper file, and in the helper file, import the components' Javascript:

```js
import "../components"
```

Then, in `app/javascript/components.js`, add:

```js
function importAll(r) {
  r.keys().forEach(r)
}

importAll(require.context("../components", true, /[_\/]component\.js$/))
```

Any file with the `_component.js` suffix (such as `app/components/widget_component.js`) will be compiled into the Webpack bundle.

#### Stimulus

In Stimulus, create a 1:1 mapping between a Stimulus controller and a component. In order to load in Stimulus controllers from the `app/components` tree, amend the Stimulus boot code in `app/javascript/packs/application.js`:

```js
const application = Application.start()
const context = require.context("controllers", true, /\.js$/)
const contextComponents = require.context("../../components", true, /_controller\.js$/)
application.load(
  definitionsFromContext(context).concat(
    definitionsFromContext(contextComponents)
  )
)
```

This enables the creation of files such as `app/components/widget_controller.js`, where the controller identifier matches the `data-controller` attribute in the component's HTML template.

After configuring Webpack to load Stimulus controller files from the `components` directory, add the path to `resolved_paths` in `config/webpacker.yml`:

```yml
  resolved_paths: ["app/components"]
```

When placing a Stimulus controller inside a sidecar directory, be aware that when referencing the controller [each forward slash in a namespaced controller file’s path becomes two dashes in its identifier](
https://stimulusjs.org/handbook/installing#controller-filenames-map-to-identifiers):

```console
app/components
├── ...
├── example
|   ├── component.rb
|   ├── component.css
|   ├── component.html.erb
|   └── component_controller.js
├── ...
```

`component_controller.js`'s Stimulus identifier becomes: `example--component`:

```erb
<div data-controller="example--component">
  <input type="text">
  <button data-action="click->example--component#greet">Greet</button>
</div>
```

## Known issues

### form_for compatibility

ViewComponent is [not currently compatible](https://github.com/github/view_component/issues/241) with `form_for` helpers.

### Inconsistent controller rendering behavior between Rails versions

In versions of Rails < 6.1, rendering a ViewComponent from a controller does not include the layout.

## Frequently Asked Questions

### Can I use other templating languages besides ERB?

Yes. ViewComponent is tested against ERB, Haml, and Slim, but it should support most Rails template handlers.

### Isn't this just like X library?

ViewComponent is far from a novel idea! Popular implementations of view components in Ruby include, but are not limited to:

- [trailblazer/cells](https://github.com/trailblazer/cells)
- [dry-rb/dry-view](https://github.com/dry-rb/dry-view)
- [komposable/komponent](https://github.com/komposable/komponent)
- [activeadmin/arbre](https://github.com/activeadmin/arbre)

## ViewComponent libraries

- [Primer ViewComponents](https://primer.style/view-components/)

## Frameworks using ViewComponent

- [Motion](https://github.com/unabridged/motion)
- [StimulusReflex](https://docs.stimulusreflex.com/)

## Resources

- [Encapsulating Views, RailsConf 2020](https://youtu.be/YVYRus_2KZM)
- [Rethinking the View Layer with Components, Ruby Rogues Podcast](https://devchat.tv/ruby-rogues/rr-461-rethinking-the-view-layer-with-components-with-joel-hawksley/)
- [ViewComponents in Action with Andrew Mason, Ruby on Rails Podcast](https://5by5.tv/rubyonrails/320)
- [ViewComponent at GitHub with Joel Hawksley](https://the-ruby-blend.fireside.fm/9)
- [Components, HAML vs ERB, and Design Systems](https://the-ruby-blend.fireside.fm/4)
- [Choosing the Right Tech Stack with Dave Paola](https://5by5.tv/rubyonrails/307)
- [Rethinking the View Layer with Components, RailsConf 2019](https://www.youtube.com/watch?v=y5Z5a6QdA-M)
- [Introducing ActionView::Component with Joel Hawksley, Ruby on Rails Podcast](http://5by5.tv/rubyonrails/276)
- [Rails to Introduce View Components, Dev.to](https://dev.to/andy/rails-to-introduce-view-components-3ome)
- [ActionView::Components in Rails 6.1, Drifting Ruby](https://www.driftingruby.com/episodes/actionview-components-in-rails-6-1)
- [Demo repository, view-component-demo](https://github.com/joelhawksley/view-component-demo)
- [Introducing ViewComponent - The Next Level In Rails Views](https://teamhq.app/blog/tech/15-introducing-viewcomponent-the-next-level-in-rails-views)

## Contributing

This project is intended to be a safe, welcoming space for collaboration. Contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct. We recommend reading the [contributing guide](./CONTRIBUTING.md) as well.

## Contributors

ViewComponent is built by:

|<img src="https://avatars.githubusercontent.com/joelhawksley?s=256" alt="joelhawksley" width="128" />|<img src="https://avatars.githubusercontent.com/tenderlove?s=256" alt="tenderlove" width="128" />|<img src="https://avatars.githubusercontent.com/jonspalmer?s=256" alt="jonspalmer" width="128" />|<img src="https://avatars.githubusercontent.com/juanmanuelramallo?s=256" alt="juanmanuelramallo" width="128" />|<img src="https://avatars.githubusercontent.com/vinistock?s=256" alt="vinistock" width="128" />|
|:---:|:---:|:---:|:---:|:---:|
|@joelhawksley|@tenderlove|@jonspalmer|@juanmanuelramallo|@vinistock|
|Denver|Seattle|Boston||Toronto|

|<img src="https://avatars.githubusercontent.com/metade?s=256" alt="metade" width="128" />|<img src="https://avatars.githubusercontent.com/asgerb?s=256" alt="asgerb" width="128" />|<img src="https://avatars.githubusercontent.com/xronos-i-am?s=256" alt="xronos-i-am" width="128" />|<img src="https://avatars.githubusercontent.com/dylnclrk?s=256" alt="dylnclrk" width="128" />|<img src="https://avatars.githubusercontent.com/kaspermeyer?s=256" alt="kaspermeyer" width="128" />|
|:---:|:---:|:---:|:---:|:---:|
|@metade|@asgerb|@xronos-i-am|@dylnclrk|@kaspermeyer|
|London|Copenhagen|Russia, Kirov|Berkeley, CA|Denmark|

|<img src="https://avatars.githubusercontent.com/rdavid1099?s=256" alt="rdavid1099" width="128" />|<img src="https://avatars.githubusercontent.com/kylefox?s=256" alt="kylefox" width="128" />|<img src="https://avatars.githubusercontent.com/traels?s=256" alt="traels" width="128" />|<img src="https://avatars.githubusercontent.com/rainerborene?s=256" alt="rainerborene" width="128" />|<img src="https://avatars.githubusercontent.com/jcoyne?s=256" alt="jcoyne" width="128" />|
|:---:|:---:|:---:|:---:|:---:|
|@rdavid1099|@kylefox|@traels|@rainerborene|@jcoyne|
|Los Angeles|Edmonton|Odense, Denmark|Brazil|Minneapolis|

|<img src="https://avatars.githubusercontent.com/elia?s=256" alt="elia" width="128" />|<img src="https://avatars.githubusercontent.com/cesariouy?s=256" alt="cesariouy" width="128" />|<img src="https://avatars.githubusercontent.com/spdawson?s=256" alt="spdawson" width="128" />|<img src="https://avatars.githubusercontent.com/rmacklin?s=256" alt="rmacklin" width="128" />|<img src="https://avatars.githubusercontent.com/michaelem?s=256" alt="michaelem" width="128" />|
|:---:|:---:|:---:|:---:|:---:|
|@elia|@cesariouy|@spdawson|@rmacklin|@michaelem|
|Milan||United Kingdom||Berlin|

|<img src="https://avatars.githubusercontent.com/mellowfish?s=256" alt="mellowfish" width="128" />|<img src="https://avatars.githubusercontent.com/horacio?s=256" alt="horacio" width="128" />|<img src="https://avatars.githubusercontent.com/dukex?s=256" alt="dukex" width="128" />|<img src="https://avatars.githubusercontent.com/dark-panda?s=256" alt="dark-panda" width="128" />|<img src="https://avatars.githubusercontent.com/smashwilson?s=256" alt="smashwilson" width="128" />|
|:---:|:---:|:---:|:---:|:---:|
|@mellowfish|@horacio|@dukex|@dark-panda|@smashwilson|
|Spring Hill, TN|Buenos Aires|São Paulo||Gambrills, MD|

|<img src="https://avatars.githubusercontent.com/blakewilliams?s=256" alt="blakewilliams" width="128" />|<img src="https://avatars.githubusercontent.com/seanpdoyle?s=256" alt="seanpdoyle" width="128" />|<img src="https://avatars.githubusercontent.com/tclem?s=256" alt="tclem" width="128" />|<img src="https://avatars.githubusercontent.com/nashby?s=256" alt="nashby" width="128" />|<img src="https://avatars.githubusercontent.com/jaredcwhite?s=256" alt="jaredcwhite" width="128" />|
|:---:|:---:|:---:|:---:|:---:|
|@blakewilliams|@seanpdoyle|@tclem|@nashby|@jaredcwhite|
|Boston, MA|New York, NY|San Francisco, CA|Minsk|Portland, OR|

|<img src="https://avatars.githubusercontent.com/simonrand?s=256" alt="simonrand" width="128" />|<img src="https://avatars.githubusercontent.com/fugufish?s=256" alt="fugufish" width="128" />|<img src="https://avatars.githubusercontent.com/cover?s=256" alt="cover" width="128" />|<img src="https://avatars.githubusercontent.com/franks921?s=256" alt="franks921" width="128" />|<img src="https://avatars.githubusercontent.com/fsateler?s=256" alt="fsateler" width="128" />|
|:---:|:---:|:---:|:---:|:---:|
|@simonrand|@fugufish|@cover|@franks921|@fsateler|
|Dublin, Ireland|Salt Lake City, Utah|Barcelona|South Africa|Chile|

|<img src="https://avatars.githubusercontent.com/maxbeizer?s=256" alt="maxbeizer" width="128" />|<img src="https://avatars.githubusercontent.com/franco?s=256" alt="franco" width="128" />|<img src="https://avatars.githubusercontent.com/tbroad-ramsey?s=256" alt="tbroad-ramsey" width="128" />|<img src="https://avatars.githubusercontent.com/jensljungblad?s=256" alt="jensljungblad" width="128" />|<img src="https://avatars.githubusercontent.com/bbugh?s=256" alt="bbugh" width="128" />|
|:---:|:---:|:---:|:---:|:---:|
|@maxbeizer|@franco|@tbroad-ramsey|@jensljungblad|@bbugh|
|Nashville, TN|Switzerland|Spring Hill, TN|New York, NY|Austin, TX|

|<img src="https://avatars.githubusercontent.com/johannesengl?s=256" alt="johannesengl" width="128" />|<img src="https://avatars.githubusercontent.com/czj?s=256" alt="czj" width="128" />|<img src="https://avatars.githubusercontent.com/mrrooijen?s=256" alt="mrrooijen" width="128" />|<img src="https://avatars.githubusercontent.com/bradparker?s=256" alt="bradparker" width="128" />|<img src="https://avatars.githubusercontent.com/mattbrictson?s=256" alt="mattbrictson" width="128" />|
|:---:|:---:|:---:|:---:|:---:|
|@johannesengl|@czj|@mrrooijen|@bradparker|@mattbrictson|
|Berlin, Germany|Paris, France|The Netherlands|Brisbane, Australia|San Francisco|

|<img src="https://avatars.githubusercontent.com/mixergtz?s=256" alt="mixergtz" width="128" />|<img src="https://avatars.githubusercontent.com/jules2689?s=256" alt="jules2689" width="128" />|<img src="https://avatars.githubusercontent.com/g13ydson?s=256" alt="g13ydson" width="128" />|<img src="https://avatars.githubusercontent.com/swanson?s=256" alt="swanson" width="128" />|<img src="https://avatars.githubusercontent.com/bobmaerten?s=256" alt="bobmaerten" width="128" />|
|:---:|:---:|:---:|:---:|:---:|
|@mixergtz|@jules2689|@g13ydson|@swanson|@bobmaerten|
|Medellin, Colombia|Toronto, Canada|João Pessoa, Brazil|Indianapolis, IN|Valenciennes, France|

|<img src="https://avatars.githubusercontent.com/nshki?s=256" alt="nshki" width="128" />|<img src="https://avatars.githubusercontent.com/nielsslot?s=256" alt="nshki" width="128" />|
|:---:|:---:|
|@nshki|@nielsslot|
|Los Angeles, CA|Amsterdam|
