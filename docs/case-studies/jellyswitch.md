# Jellyswitch

Name: Dave Paola

Github Handle: [@dpaola2](https://github.com/dpaola2)

[Jellyswitch](https://www.jellyswitch.com) is a coworking space management platform

In response to [this tweet](https://twitter.com/joelhawksley/status/1232674647327547394):

I recently began refactoring many of my partials into components. Along the way I discovered an interesting use case, which was to componentize the various bootstrap components I was already using.

Some examples:

- I've componentized the specific layout that I've designed using the grid system. I have defined a `FullWidthLayout` component that wraps its contents in the correct classes to give my layout a good design on both mobile and desktop. (On desktop, there is a sidebar, and on mobile, the sidebar floats on top in a collapsed fashion.)
- [Modals](https://getbootstrap.com/docs/4.4/components/modal/) are now componentized and accept arguments. I had them as partials before, but having ruby classes is an upgrade.
- [Breadcrumbs](https://getbootstrap.com/docs/4.4/components/breadcrumb/) same as above.

Here's one that I use a LOT: `OnOffSwitch`:

```ruby
class OnOffSwitch < ApplicationComponent
  def initialize(predicate:, path:, disabled: false, label: nil)
    @predicate = predicate
    @path = path
    @disabled = disabled
    @label = label
  end

  private

  attr_reader :predicate, :path, :disabled, :label

  def icon_class
    if predicate
      "fas fa-toggle-on"
    else
      "fas fa-toggle-off"
    end
  end
end
```

```erb
<div class="d-flex align-items-center">
  <% if !disabled %>
    <%= link_to path, class: "text-body", remote: true do %>
      <span style="font-size: 20pt">
        <% if predicate %>
          <span class="text-success">
            <i class="<%= icon_class %>"></i>
          </span>
        <% else %>
          <span class="text-danger">
            <i class="<%= icon_class %>"></i>
          </span>
        <% end %>
      </span>
    <% end %>
  <% else %>
    <span style="font-size: 20pt">
      <span class="text-muted">
        <i class="<%= icon_class %>"></i>
      </span>
    </span>
  <% end %>
  &nbsp;
  <%= content %>
</div>
```

Here is an example of how this looks:

<img width="653" alt="Screenshot 2020-02-26 08 34 07" src="https://user-images.githubusercontent.com/150509/75365920-cbfb9500-5872-11ea-8234-f1343629a462.png">

I have found that refactoring complex views is made easier and faster by first putting them into a component, extracting the conditionals and other logic into private methods and proceeding from there. And I wind up with a very nice set of well-factored components and sub-components, with argument lists and validations and so on. I think the rails community is really going to benefit from this library, and I'm hugely appreciative of y'all's efforts on it!

I plan to release an early version of the bootstrap components we've developed at some point in the near future. I would love to collaborate and learn the most appropriate way to structure that contribution.
