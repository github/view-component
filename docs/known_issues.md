---
layout: default
title: Known issues
---

# Known issues

## form_for compatibility

ViewComponent is [not currently compatible](https://github.com/github/view_component/issues/241) with `form_for` helpers.

## Inconsistent controller rendering behavior between Rails versions

In versions of Rails < 6.1, rendering a ViewComponent from a controller does not include the layout.
