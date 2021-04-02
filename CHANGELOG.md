# CHANGELOG

## main

* Experimental: call `._sidecar_files` to fetch the sidecar files for a given list of extensions, e.g. passing `["yml", "yaml"]`.

    *Elia Schito*

* Fix bug where a single `jbuilder` template matched multiple template handlers.

    *Niels Slot*

## 2.28.0

* Include SlotableV2 by default in Base. **Note:** It's no longer necessary to include `ViewComponent::SlotableV2` to use Slots.

    *Joel Hawksley*

* Prepend Preview routes instead of appending, accounting for cases where host application has catchall route.

    *Joel Hawksley*

* Fix bug where blocks passed to lambda slots will render incorrectly in certain situations.

    *Blake Williams*

## 2.27.0

* Allow customization of the controller used in component tests.

    *Alex Robbin*

* Generate preview at overridden path if one exists when using `--preview` flag.

    *Nishiki Liu*

## 2.26.1

* Fix bug that raises when trying to use a collection before the component has been compiled.

    *Blake Williams*

## 2.26.0

* Lazily evaluate component `content` in `render?`, preventing the `content` block from being evaluated when `render?` returns false.

    *Blake Williams*

* Do not generate template when using `--inline` flag.

    *Hans Lemuet*

* Add `--inline` option to the Haml and Slim generators

    *Hans Lemuet*

## 2.25.1

* Experimental: call `._after_compile` class method after a component is compiled.

    *Joel Hawksley*

* Fix bug where SlotV2 was rendered as an HTML string when using Slim.

    *Manuel Puyol*

## 2.25.0

* Add `--preview` generator option to create an associated preview file.

    *Bob Maerten*

* Add argument validation to avoid `content` override.

    *Manuel Puyol*

## 2.24.0

* Add `--inline` option to the erb generator. Prevents default erb template from being created and creates a component with a call method.

    *Nachiket Pusalkar*

* Add test case for checking presence of `content` in `#render?`.

    *Joel Hawksley*

* Rename `master` branch to `main`.

    *Joel Hawksley*

## 2.23.2

* Fix bug where rendering a component `with_collection` from a controller raised an error.

    *Joel Hawksley*

## 2.23.1

* Fixed out-of-order rendering bug in `ActionView::SlotableV2`

    *Blake Williams*

## 2.23.0

* Add `ActionView::SlotableV2`
  * `with_slot` becomes `renders_one`.
  * `with_slot collection: true` becomes `renders_many`.
  * Slot definitions now accept either a component class, component class name, or a lambda instead of a `class_name:` keyword argument.
  * Slots now support positional arguments.
  * Slots no longer use the `content` attribute to render content, instead relying on `to_s`. e.g. `<%= my_slot %>`.
  * Slot values are no longer set via the `slot` method, and instead use the name of the slot.

    *Blake Williams*

* Add `frozen_string_literal: true` to generated component template.

    *Max Beizer*

## 2.22.1

* Revert refactor that broke rendering for some users.

    *Joel Hawksley*

## 2.22.0

* Add #with_variant to enable inline component variant rendering without template files.

    *Nathan Jones*

## 2.21.0

* Only compile components at application initialization if eager loading is enabled.

    *Joel Hawksley*

## 2.20.0

* Don't add `/test/components/previews` to preview_paths if directory doesn't exist.

    *Andy Holland*

* Add `preview_controller` option to override the controller used for component previews.

    *Matt Swanson, Blake Williams, Juan Manuel Ramallo*

## 2.19.1

* Check if `Rails.application` is loaded.

    *Gleydson Tavares*

* Add documentation for webpack configuration when using Stimulus controllers.

    *Ciprian Redinciuc*

## 2.19.0

* Extend documentation for using Stimulus within sidecar directories.

    *Ciprian Redinciuc*

* Subclassed components inherit templates from parent.

    *Blake Williams*

* Fix uninitialized constant error from `with_collection` when `eager_load` is disabled.

    *Josh Gross*

## 2.18.2

* Raise an error if controller or view context is accessed during initialize as they are only available in render.

    *Julian Nadeau*

* Collate test coverage across CI builds, ensuring 100% test coverage.

    *Joel Hawksley*

## 2.18.1

* Fix bug where previews didn't work when monkey patch was disabled.

    *Mixer Gutierrez*

## 2.18.0

* Fix auto-loading of previews (changes no longer require a server restart)

    *Matt Brictson*

* Add `default_preview_layout` configuration option to load custom app/views/layouts.

    *Jared White, Juan Manuel Ramallo*

* Calculate virtual_path once for all instances of a component class to improve performance.

    *Brad Parker*

## 2.17.1

* Fix bug where rendering Slot with empty block resulted in error.

    *Joel Hawksley*

## 2.17.0

* Slots return stripped HTML, removing leading and trailing whitespace.

    *Jason Long, Joel Hawksley*

## 2.16.0

* Add `--sidecar` option to the erb, haml and slim generators. Places the generated template in the sidecar directory.

    *Michael van Rooijen*

## 2.15.0

* Add support for templates as ViewComponent::Preview examples.

    *Juan Manuel Ramallo

## 2.14.1

* Allow using `render_inline` in test when the render monkey patch is disabled with `config.view_component.render_monkey_patch_enabled = false` in versions of Rails < 6.1.

    *Clément Joubert*

* Fix kwargs warnings in slotable.

    Fixes:

    ```console
    view_component/lib/view_component/slotable.rb:98: warning: Using the last argument as keyword parameters is deprecated; maybe ** should be added to the call
    view_component/test/app/components/slots_component.rb:18: warning: The called method `initialize' is defined here
    ```

    *Eileen M. Uchitelle*

## 2.14.0

* Add `config.preview_paths` to support multiple locations of component preview files. Deprecate `config.preview_path`.

    *Tomas Celizna*

* Only print warning about a missing capybara dependency if the `DEBUG` environment variable is set.

    *Richard Macklin*

## 2.13.0

* Add the ability to disable the render monkey patch with `config.view_component.render_monkey_patch_enabled`. In versions of Rails < 6.1, add `render_component` and `render_component_to_string` methods which can be used for rendering components instead of `render`.

    *Johannes Engl*

## 2.12.0

* Implement Slots as potential successor to Content Areas.

    *Jens Ljungblad, Brian Bugh, Jon Palmer, Joel Hawksley*

## 2.11.1

* Fix kwarg warnings in Ruby 2.7.

    *Joel Hawksley*

## 2.11.0

* Ensure Rails configuration is available within components.

    *Trevor Broaddus*

* Fix bug where global Rails helpers are inaccessible from nested components. Before, `helpers` was pointing to parent component.

    *Franco Sebregondi*

## 2.10.0

* Raise an `ArgumentError` with a helpful message when Ruby cannot parse a component class.

    *Max Beizer*

## 2.9.0

* Cache components per-request in development, preventing unnecessary recompilation during a single request.

    *Felipe Sateler*

## 2.8.0

* Add `before_render`, deprecating `before_render_check`.

    *Joel Hawksley*

## 2.7.0

* Add `rendered_component` method to `ViewComponent::TestHelpers` which exposes the raw output of the rendered component.

    *Richard Macklin*

* Support sidecar directories for views and other assets.

    *Jon Palmer*

## 2.6.0

* Add `config.view_component.preview_route` to set the endpoint for component previews. By default `/rails/view_components` is used.

    *Juan Manuel Ramallo*

* Raise error when initializer omits with_collection_parameter.

    *Joel Hawksley*

## 2.5.1

* Compile component before rendering collection.

    *Rainer Borene*

## v2.5.0

* Add counter variables when rendering collections.

    *Frank S*

* Add the ability to access params from preview examples.

    *Fabio Cantoni*

## v2.4.0

* Add `#render_to_string` support.

   *Jarod Reid*

* Declare explicit dependency on `activesupport`.

    *Richard Macklin*

* Remove `autoload`s of internal modules (`Previewable`, `RenderMonkeyPatch`, `RenderingMonkeyPatch`).

    *Richard Macklin*

* Remove `capybara` dependency.

    *Richard Macklin*

## v2.3.0

* Allow using inline render method(s) defined on a parent.

    *Simon Rand*

* Fix bug where inline variant render methods would never be called.

    *Simon Rand*

* ViewComponent preview index views use Rails internal layout instead of application's layout

    *Juan Manuel Ramallo*

## v2.2.2

* Add `Base.format` for better compatibility with `ActionView::Template`.

    *Joel Hawksley*

## v2.2.1

* Fix bug where template could not be found if `inherited` was redefined.

    *Joel Hawksley*

## v2.2.0

* Add support for `config.action_view.annotate_template_file_names` (coming in Rails 6.1).

    *Joel Hawksley*

* Remove initializer requirement from the component.

    *Vasiliy Ermolovich*

## v2.1.0

* Support rendering collections (e.g., `render(MyComponent.with_collection(@items))`).

    *Tim Clem*

## v2.0.0

* Move to `ViewComponent` namespace, removing all references to `ActionView`.

  * The gem name is now `view_component`.
  * ViewComponent previews are now accessed at `/rails/view_components`.
  * ViewComponents can _only_ be rendered with the instance syntax: `render(MyComponent.new)`. Support for all other syntaxes has been removed.
  * ActiveModel::Validations have been removed. ViewComponent generators no longer include validations.
  * In Rails 6.1, no monkey patching is used.
  * `to_component_class` has been removed.
  * All gem configuration is now in `config.view_component`.

## v1.17.0

* Support Ruby 2.4 in CI.

    *Andrew Mason*

* ViewComponent generators do not not prompt for content requirement.

    *Joel Hawksley*

* Add post-install message that gem has been renamed to `view_component`.

    *Joel Hawksley*

## v1.16.0

* Add `refute_component_rendered` test helper.

    *Joel Hawksley*

* Check for Rails before invocation.

    *Dave Paola*

* Allow components to be rendered without a template file (aka inline component).

    *Rainer Borene*

## v1.15.0

* Re-introduce ActionView::Component::TestHelpers.

    *Joel Hawksley*

* Bypass monkey patch on Rails 6.1 builds.

    *Joel Hawksley*

* Make `ActionView::Helpers::TagHelper` available in Previews.

    ```ruby
    def with_html_content
      render(MyComponent.new) do
        tag.div do
          content_tag(:span, "Hello")
        end
      end
    end
    ```

    *Sean Doyle*

## v1.14.1

* Fix bug where generator created invalid test code.

    *Joel Hawksley*

## v1.14.0

* Rename ActionView::Component::Base to ViewComponent::Base

    *Joel Hawksley*

## v1.13.0

* Allow components to be rendered inside controllers.

    *Joel Hawksley*

* Improve backtraces from exceptions raised in templates.

    *Blake Williams*

## v1.12.0

* Revert: Remove initializer requirement for Ruby 2.7+

    *Joel Hawksley*

* Restructure Railtie into Engine

    *Sean Doyle*

* Allow components to override before_render_check

    *Joel Hawksley*

## v1.11.1

* Relax Capybara requirement.

    *Joel Hawksley*

## v1.11.0

* Add support for Capybara matchers.

    *Joel Hawksley*

* Add erb, haml, & slim template generators

    *Asger Behncke Jacobsen*

## v1.10.0

* Deprecate all `render` syntaxes except for `render(MyComponent.new(foo: :bar))`

    *Joel Hawksley*

## v1.9.0

* Remove initializer requirement for Ruby 2.7+

    *Dylan Clark*

## v1.8.1

* Run validation checks before calling `#render?`.

    *Ash Wilson*

## v1.8.0

* Remove the unneeded ComponentExamplesController and simplify preview rendering.

    *Jon Palmer*

* Add `#render?` hook to easily allow components to be no-ops.

    *Kyle Fox*

* Don't assume ApplicationController exists.

    *Jon Palmer*

* Allow some additional checks to overrided render?

    *Sergey Malykh*

* Fix generator placing namespaced components in the root directory.

    *Asger Behncke Jacobsen*

* Fix cache test.

    *Sergey Malykh*

## v1.7.0

* Simplify validation of templates and compilation.

    *Jon Palmer*

* Add support for multiple content areas.

    *Jon Palmer*

## v1.6.2

* Fix Uninitialized Constant error.

    *Jon Palmer*

* Add basic github issue and PR templates.

    *Dylan Clark*

* Update readme phrasing around previews.

    *Justin Coyne*

## v1.6.1

* Allow Previews to have no layout.

    *Jon Palmer*

* Bump rack from 2.0.7 to 2.0.8.

    *Dependabot*

* Compile components on application boot when eager loading is enabled.

    *Joel Hawksley*

* Previews support content blocks.

    *Cesario Uy*

* Follow Rails conventions. (refactor)

    *Rainer Borene*

* Fix edge case issue with extracting variants from less conventional source_locations.

    *Ryan Workman*

## v1.6.0

* Avoid dropping elements in the render_inline test helper.

    *@dark-panda*

* Add test for helpers.asset_url.

    *Christopher Coleman*

* Add rudimentary compatibility with better_html.

    *Joel Hawksley*

* Template-less variants fall back to default template.

    *Asger Behncke Jacobsen*, *Cesario Uy*

* Generated tests use new naming convention.

    *Simon Træls Ravn*

* Eliminate sqlite dependency.

    *Simon Dawson*

* Add support for rendering components via #to_component_class

    *Vinicius Stock*

## v1.5.3

* Add support for RSpec to generators.

    *Dylan Clark, Ryan Workman*

* Require controllers as part of setting autoload paths.

    *Joel Hawksley*

## v1.5.2

* Disable eager loading initializer.

    *Kasper Meyer*

## v1.5.1

* Update railties class to work with Rails 6.

    *Juan Manuel Ramallo*

## v1.5.0

Note: `actionview-component` is now loaded by requiring `actionview/component`, not `actionview/component/base`.

* Fix issue with generating component method signatures.

    *Ryan Workman, Dylan Clark*

* Create component generator.

    *Vinicius Stock*

* Add helpers proxy.

    *Kasper Meyer*

* Introduce ActionView::Component::Previews.

    *Juan Manuel Ramallo*

## v1.4.0

* Fix bug where components broke in application paths with periods.

    *Anton, Joel Hawksley*

* Add support for `cache_if` in component templates.

    *Aaron Patterson, Joel Hawksley*

* Add support for variants.

    *Juan Manuel Ramallo*

* Fix bug in virtual path lookup.

    *Juan Manuel Ramallo*

* Preselect the rendered component in render_inline.

    *Elia Schito*

## v1.3.6

* Allow template file names without format.

    *Joel Hawksley*

* Add support for translations.

    *Juan Manuel Ramallo*

## v1.3.5

* Re-expose `controller` method.

    *Michael Emhofer, Joel Hawksley*

* Gem version numbers are now accessible through `ActionView::Component::VERSION`

    *Richard Macklin*

* Fix typo in README

    *ars moriendi*

## v1.3.4

* Template errors surface correct file and line number.

    *Justin Coyne*

* Allow access to `request` inside components.

    *Joel Hawksley*

## v1.3.3

* Do not raise error when sidecar files that are not templates exist.

    *Joel Hawksley*

## v1.3.2

* Support rendering views from inside component templates.

    *Patrick Sinclair*

## v1.3.1

* Fix bug where rendering nested content caused an error.

    *Joel Hawksley, Aaron Patterson*

## v1.3.0

* Components are rendered with enough controller context to support rendering of partials and forms.

    *Patrick Sinclair, Joel Hawksley, Aaron Patterson*

## v1.2.1

* `actionview-component` is now tested against Ruby 2.3/2.4 and Rails 5.0.0.

## v1.2.0

* The `render_component` test helper has been renamed to `render_inline`. `render_component` has been deprecated and will be removed in v2.0.0.

    *Joel Hawksley*

* Components are now rendered with `render MyComponent, foo: :bar` syntax. The existing `render MyComponent.new(foo: :bar)` syntax has been deprecated and will be removed in v2.0.0.

    *Joel Hawksley*

## v1.1.0

* Components now inherit from ActionView::Component::Base

    *Joel Hawksley*

## v1.0.1

* Always recompile component templates outside production.

    *Joel Hawksley, John Hawthorn*

## v1.0.0

This release extracts the `ActionView::Component` library from the GitHub application.

It will be published on RubyGems under the existing `actionview-component` gem name, as @chancancode has passed us ownership of the gem.
