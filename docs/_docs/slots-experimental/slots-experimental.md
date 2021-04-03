---
layout: default
title: Slots (experimental)
nav_order: 7
has_children: true
permalink: /docs/slots-experimental
---

## Slots (experimental)

_Slots are currently under development as a successor to Content Areas. The Slot APIs should be considered unfinished and subject to breaking changes in non-major releases of ViewComponent._

Slots enable multiple blocks of content to be passed to a single ViewComponent, reducing the need for sub-components \(e.g. ModalHeader, ModalBody\).

By default, slots can be rendered once per component. They provide an accessor with the name of the slot \(`#header`\) that returns an instance of `ViewComponent::Slot`, etc.

Slots declared with `collection: true` can be rendered multiple times. They provide an accessor with the pluralized name of the slot \(`#rows`\), which is an Array of `ViewComponent::Slot` instances.

To learn more about the design of the Slots API, see [\#348](https://github.com/github/view_component/pull/348) and [\#325](https://github.com/github/view_component/discussions/325).
