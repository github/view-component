---
layout: default
title: Known issues
---

# Known issues

## Compatibility with Rails Forms

ViewComponent works for most cases using form helpers in Rails. See the [forms](practical-examples/forms.md) guide in the Practical Examples section for more information on compatibility.

## Inconsistent controller rendering behavior between Rails versions

In versions of Rails < 6.1, rendering a ViewComponent from a controller does not include the layout.
