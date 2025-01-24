---
layout: default
title: Compatibility
nav_order: 6
---

# Compatibility

## Ruby & Rails

ViewComponent supports all actively supported versions of [Ruby](https://endoflife.date/ruby) (>= 3.2) and [Ruby on Rails](https://endoflife.date/rails) (>= 7.1). Changes to the minimum Ruby and Rails versions supported will only be made in major releases.

## Template languages

ViewComponent is tested against ERB, Haml, and Slim, but it should support most Rails template handlers.

## Bridgetown (Static Site Generator)

[Bridgetown](https://www.bridgetownrb.com/) supports ViewComponent via an experimental shim provided by the [bridgetown-view-component gem](https://github.com/bridgetownrb/bridgetown-view-component). More information available [here](https://www.bridgetownrb.com/docs/components/ruby#need-compatibility-with-rails-try-viewcomponent-experimental).

## ActionText

Using `rich_textarea` from ActionText in a ViewComponent will result in this error:

`undefined method "rich_textarea_tag"`

This is due to ViewComponent not having access to the helpers it needs via ActionText. As a workaround, add the following to your component (or base component):

```ruby
delegate :rich_textarea_tag, to: :helpers
```
