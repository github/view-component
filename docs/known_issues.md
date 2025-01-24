---
layout: default
title: Known issues
nav_order: 9
---

# Known issues

_There remain several known issues with ViewComponent. We'd be thrilled to see you consider solutions to these thorny bugs!_

## Limited i18n support

ViewComponent currently only supports sidecar translation files. In some cases, it could be useful to support centralized translations using namespacing:

```yml
en:
  view_components:
    login_form:
      submit: "Log in"
    nav:
      user_info:
        login: "Log in"
        logout: "Log out"
```

## Lack of Jekyll support

It would be lovely if we could support rendering ViewComponents in Jekyll, as it would enable the reuse of ViewComponents across static and dynamic (Rails-based) sites.

## Issues resolved by the optional capture compatibility patch

If you're experiencing issues with duplicated content or malformed HTML output (such as using `concat` in a helper), the capture compatibility patch may resolve these.

[Set `config.view_component.capture_compatibility_patch_enabled` to `true`](https://viewcomponent.org/api.html#capture_compatibility_patch_enabled) to resolve these issues.

These issues arise because the related features/methods keep a reference to the
primary `ActionView::Base` instance, which has its own `@output_buffer`. When
`#capture` is called on the original `ActionView::Base` instance while
evaluating a block from a ViewComponent, the `@output_buffer` is overridden in
the `ActionView::Base` instance, and *not* the component. This results in a
double render due to `#capture` implementation details.

To resolve the issue, we override `#capture` so that we can delegate the
`capture` logic to the ViewComponent that created the block.

### turbo_frame_tag double rendering or scrambled HTML structure

When using `turbo_frame_tag` inside a ViewComponent, the template may be rendered twice. See [https://github.com/github/view_component/issues/1099](https://github.com/github/view_component/issues/1099).

As a workaround, use `tag.turbo_frame` instead of `turbo_frame_tag`.

Note: For the same functionality as `turbo_frame_tag(my_model)`, use `tag.turbo_frame(id: dom_id(my_model))`.

### Compatibility with Rails form helpers

ViewComponent [isn't compatible](https://github.com/viewcomponent/view_component/issues/241) with `form_for` helpers by default.

Passing a form object (often `f`) to a ViewComponent works for simple cases like `f.text_field :name`. Content may be ill-ordered or duplicated in complex cases, such as passing blocks to form helpers or when nesting components.

Some workarounds include:

- Experimental: Enable the capture compatibility patch with `config.view_component.capture_compatibility_patch_enabled = true`.
- Render an entire form within a single ViewComponent.
- Render a [partial](https://guides.rubyonrails.org/layouts_and_rendering.html#using-partials) within the ViewComponent which includes the form.
- Use a [custom `FormBuilder`](https://guides.rubyonrails.org/form_helpers.html#customizing-form-builders) to create reusable form components:
  - Using FormBuilder with [Action View helpers](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html).
  - Using a FormBuilder overriding all field helpers to render a ViewComponent so each field can be customized individually (for example, [view_component-form](https://github.com/pantographe/view_component-form)).
  - Using a lightweight re-implementation of ViewComponent. For example, [Primer ViewComponents](https://github.com/primer/view_components) implemented [`ActsAsComponent`](https://github.com/primer/view_components/blob/main/lib/primer/forms/acts_as_component.rb) which is used in the context of `FormBuilder`.

## Forms don't use the default `FormBuilder`

Calls to form helpers such as `form_with` in ViewComponents [don't use the default form builder](https://github.com/viewcomponent/view_component/pull/1090#issue-753331927). This is by design, as it allows global state to change the rendered output of a component. Instead, consider passing a form builder into form helpers via the `builder` argument:

```html.erb
<%= form_for(record, builder: CustomFormBuilder) do |f| %>
  <%= f.text_field :name %>
<% end %>
```
