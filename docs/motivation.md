---
layout: default
title: Motivation
nav_order: 2
---


# Motivation

## What are ViewComponents?

ViewComponents are Ruby objects that output HTML. Think of them as an evolution of the presenter pattern, inspired by [React](https://reactjs.org/docs/react-component.html).

## When should I use ViewComponents?

ViewComponents are most effective in cases where view code is reused or benefits from being tested directly. Heavily reused partials and templates with significant amounts of embedded Ruby often make good ViewComponents.

## Why should I use ViewComponents?

### Testing

Unlike traditional Rails views, ViewComponents can be unit-tested. In the GitHub codebase, ViewComponent unit tests take around 25 milliseconds each, compared to about six seconds for controller tests.

Rails views are typically tested with slow integration tests that also exercise the routing and controller layers in addition to the view. This cost often discourages thorough test coverage.

With ViewComponent, integration tests can be reserved for end-to-end assertions, with permutations and corner cases covered at the unit level.

### Data Flow

Traditional Rails views have an implicit interface, making it hard to reason about what information is needed to render, leading to subtle bugs when rendering the same view in different contexts.

ViewComponents use a standard Ruby initializer that clearly defines what is needed to render, making them easier (and safer) to reuse than partials.

### Performance

Based on our [benchmarks](https://github.com/github/view_component/blob/main/performance/benchmark.rb), ViewComponents are ~10x faster than partials.

### Standards

Views often fail basic Ruby code quality standards: long methods, deep conditional nesting, and mystery guests abound.

ViewComponents are Ruby objects, making it easy to follow (and enforce) code quality standards.
