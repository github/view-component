---
layout: default
title: Translations
parent: Building ViewComponents
---

# Translations (experimental)

To use experimental support for `I18n` translations, include `ViewComponent::Translatable`:

`app/components/example_component.rb`

```ruby
module ExampleComponent < ApplicationComponent
  include ViewComponent::Translatable
end
```

Add a sidecar YAML file with translations for the component:

`app/components/example_component.yml`

```yml
en:
  hello: "Hello world!"
```

Access component-local translations with a leading dot:

`app/components/example_component.html.erb`

```erb
<%= t(".hello") %>
```

Global Rails translations are available as well:

```erb
<%= t("my.global.translation") %>
```

Global translations shadowed by sidecar translations can be accessed with `helpers` or `I18n`:

`app/components/example_component.html.erb`

```erb
<%= helpers.t("hello") %>
<%= I18n.t("hello") %>
```
