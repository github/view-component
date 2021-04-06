# CSS encapsulation

Date: March 22, 2021

## Status

Proposed

## Context

At GitHub, we have a large amount of custom CSS that has become difficult to manage. More generally, writing CSS at scale is often fraught with pitfalls: it's all too easy to introduce visual regressions due to the global nature of the language.

We've seen success in using [CSS-in-JS](https://www.youtube.com/watch?v=ull9iCMTGDE) with [Primer React](https://primer.style/components/), which is built with [Styled Components](https://styled-components.com).

Over the past couple of months, we've experimented with bringing encapsulated CSS to Rails with ViewComponent, with the hope of addressing several key problems:

### Scoping

It's trivial to write CSS that has unintended consequences. By scoping styles using hashed class name selectors, this problem is unlikely.

### Critical CSS

In at least one case, we only use 3% of our main CSS bundle on a page, meaning a user downloads over 400kb of data they aren't using. By only serving the CSS for ViewComponents rendered in the current request, we can deliver only the CSS necessary to render a page.

### Dead code elimination

It can be hard to know if it's safe to remove CSS from a codebase. With encapsulation, it's safe to delete a component's CSS.

## Decision

We will implement significant portions of the long-standing [CSS Modules spec](https://github.com/css-modules/css-modules) natively in ViewComponent for [encapsulated styles](https://medium.com/seek-blog/the-end-of-global-css-90d2a4a06284):

### No Webpacker

The proposed design avoids Webpacker and other build tools. Instead, it uses a Ruby implementation of CSS Modules built by @rmosolgo, enabling greater portability and a convention-over-configuration experience that Rails developers expect.

### No bundles

The proposed design eschews the concept of shipping CSS in bundles, with the goal of encouraging the delivery of only the CSS needed to render a give page.

### No global syntax

In keeping with the existing ViewComponent encapsulation mental model, all styles are locally scoped by default, with no global escape hatch.

### No SCSS

We're not very sure about this one, but we're playing with the idea of just using plain CSS, at least to start.

## Alternatives we considered

### CSS-in-Ruby

Much like our issue with [inlining ERB inside ViewComponent Ruby files](https://github.com/github/view_component/commit/5d3806a2a9ec0187574ac6c64a0ae90e655691ae#diff-b335630551682c19a781afebcf4d07bf978fb1f8ac04c6bf87428ed5106870f5R173), writing CSS inline (like Styled Components and others do) raised similar concerns over compatibility with Ruby 3 type systems.

### Ruby-in-CSS

We considered allowing for evaluation of Ruby inside CSS files (at compile, runtime, or both) but instead decided to lean on [CSS custom properties](https://developer.mozilla.org/en-US/docs/Web/CSS/Using_CSS_custom_properties) for injecting dynamic values. The recent Dark Mode feature heavily depended on CSS variables.

### Bundle splitting

We attempted to split our CSS into multiple smaller bundles without significant success. We found it hard to be confident that such changes weren't breaking our UI in subtle ways. Ensuring heavily reused templates always rendered with their corresponding styles proved to be practically impossible.

## Consequences

o, avoiding several common errors and resulting in more resilient user interfaces.
