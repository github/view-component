---
layout: default
title: Defining Slots
parent: Slots (experimental)
nav_order: 2
---

## Defining Slots

Slots are defined by `with_slot`:

`with_slot :header`

To define a collection slot, add `collection: true`:

`with_slot :row, collection: true`

To define a slot with a custom Ruby class, pass `class_name`:

`with_slot :body, class_name: 'BodySlot'`

_Note: Slot classes must be subclasses of `ViewComponent::Slot`._
