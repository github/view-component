# ActionView::Component
`ActionView::Component` is a framework for building view components in Rails.

**Current Status**: Used in production at GitHub. Because of this, all changes will be thoroughly vetted, which could slow down the process of contributing. We will do our best to actively communicate status of pull requests with any contributors. If you have any substantial changes that you would like to make, it would be great to first [open an issue](http://github.com/github/actionview-component/issues/new) to discuss them with us.

## Roadmap

This gem is meant to serve as a precursor to upstreaming the `ActionView::Component` class into Rails. It also serves to enable the usage of `ActionView::Component` in older versions of Rails.

Preliminary support for rendering components was merged into Rails `6.1.0.alpha` in https://github.com/rails/rails/pull/36388. Assuming `ActionView::Component` makes it into Rails `6.1`, this gem will then exist to serve as a backport.

## Compatibility

`actionview-component` is tested for compatibility with all combinations of Ruby `2.5`/`2.6` and Rails `5.2.3`/`6.0.0.rc2`/`6.1.0.alpha`.

## Installation
Add this line to your application's Gemfile:

```ruby
gem "actionview-component"
```

And then execute:
```bash
$ bundle
```

In `config/application.rb`, add:

```bash
require "action_view/component"
```

## Guide

### What are components?

`ActionView::Component`s are Ruby classes that are used to render views. They take data as input and return output-safe HTML. Think of them as an evolution of the presenter/decorator/view model pattern, inspired by [React Components](https://reactjs.org/docs/react-component.html).

### Why components?

Traditional Rails views are hard to test efficiently, difficult to measure with code coverage tools, and often fall short of basic Ruby code standards.

Components allow us to test our views in isolation, use code coverage tools, and leverage Ruby to its full potential.

### When should I use components?

Components are most effective in cases where view code is reused or needs to be tested directly.

### Using components

Render components by passing an instance to `#render`:

```erb
<div class="container">
  <%= render Greeting.new(name: "Sarah") %>
</div>
```

### Building components

Components are subclasses of `ActionView::Component`. You may wish to create an `ApplicationComponent` that is a subclass of `ActionView::Component` and inherit from that instead.

#### Implementation

An `ActionView::Component` is implemented as a Ruby file alongside a template file (in any format supported by Rails) with the same base name:

`app/components/greeting.html.erb`
```erb
<h1>Hello, <%= name %></h1>
```

`app/components/greeting.rb`
```ruby
class Greeting < ActionView::Component
  def initialize(name:)
    @name = name
  end

  private

  attr_reader: :name
end
```

Generally, only the `initialize` method should be public.

#### Validations

`ActionView::Component` includes `ActiveModel::Validations`, so components can validate their attributes:

```ruby
class Greeting < ActionView::Component
  validates :name, length: { minimum: 2, maximum: 50 }

  def initialize(name:)
    @name = name
  end

  private

  attr_reader :name
end
```

#### Rendering content

Components can also render content passed as a block. To do so, simply return `content` inside the template:

`app/components/heading.rb`
```ruby
class Heading < ActionView::Component
end
```

`app/components/heading.html.erb`
```erb
<h1><%= content %></h1>
```

Under the hood, `ActionView::Component` captures the output of the passed block within the context of the original view and assigns it to `content`.

In use:

```ruby
<%= render Heading.new do %>Components are fun!<% end %>
```

Returns:

`<h1>Components are fun!</h1>`

## Resources

- [Rethinking the View Layer with Components, RailsConf 2019](https://www.youtube.com/watch?v=y5Z5a6QdA-M)
- [Introducing ActionView::Component with Joel Hawksley, Ruby on Rails Podcast](http://5by5.tv/rubyonrails/276)
- [Rails to Introduce View Components, Dev.to](https://dev.to/andy/rails-to-introduce-view-components-3ome)
- [ActionView::Components in Rails 6.1, Drifting Ruby](https://www.driftingruby.com/episodes/actionview-components-in-rails-6-1)
- [Demo repository, actionview-component-demo](https://github.com/joelhawksley/actionview-component-demo)

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/github/actionview-component. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct. We recommend reading the [contributing guide](./CONTRIBUTING.md) as well.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
