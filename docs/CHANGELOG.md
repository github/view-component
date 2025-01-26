---
layout: default
title: Changelog
nav_order: 5
---

<!-- Add unreleased changes under the "main" heading. -->

# Changelog

## main

* Remove JS and CSS docs as they proved difficult to maintain and lacked consensus.

    *Joel Hawksley*

* Do not prefix release tags with `v`, per recommendation from @bkuhlmann.

    *Joel Hawksley*

* Add ruby 3.4 support to CI.

    *Reegan Viljoen*

* Add first class component cache.

    *Reegan Viljoen*

## 3.21.0

* Updates testing docs to include an example of how to use with RSpec.

    *Rylan Bowers*

* Add `--skip-suffix` option to component generator.

    *KAWAKAMI Moeki*

* Add FreeATS to list of companies using ViewComponent.

    *Ilia Liamshin*

* Ensure HTML output safety wrapper is used for all inline templates.

    *Joel Hawksley*

* Expose `.identifier` method as part of public API.

    *Joel Hawksley*

* Add rails 8 support to CI.

    *Reegan Viljoen*

* Updates ActionText compatibility documentation to reference `rich_textarea_tag` for Rails 8.0 support.

    *Alvin Crespo*

## 3.20.0

* Allow rendering `with_collection` to accept an optional `spacer_component` to be rendered between each item.

    *Nick Coyne*

* Remove OpenStruct from codebase.

    *Oleksii Vasyliev*

## 3.19.0

* Relax Active Support version constraint in gemspec.

    *Simon Fish*

## 3.18.0

* Enable components to use `@request` and `request` methods/ivars.

    *Blake Williams*

* Fix bug where implicit locales in component filenames threw a `NameError`.

    *Chloe Fons*

* Register ViewComponent tests directory for `rails stats`.

    *Javier Aranda*

* Wrap entire compile step in a mutex to make it more resilient to race conditions.

    *Blake Williams*

* Add [Niva]([niva.co](https://www.niva.co/)) to companies who use `ViewComponent`.

    *Daniel Vu Dao*

* Fix `preview_paths` in docs.

    *Javier Aranda*

## 3.17.0

* Use struct instead openstruct in lib code.

    *Oleksii Vasyliev*

* Fix bug where stimulus controller was not added to ERB when stimulus was activated by default.

    *Denis Pasin*

* Add typescript support to stimulus generator.

    *Denis Pasin*

* Fix the example of #vc_test_request in the API reference to use the correct method name.

    *Alberto Rocha*

* Fix development mode race condition that caused an invalid duplicate template error.

    *Blake Williams*

## 3.16.0

* Add template information to multiple template error messages.

    *Joel Hawksley*

* Add `ostruct` to gemspec file to suppress stdlib removal warning.

    *Jonathan Underwood*

## 3.15.1

* Re-add `@private`, undocumented `.identifier` method that was only meant for internal framework use but was used by some downstream consumers. This method will be removed in a coming minor release.

    *Joel Hawksley*

## 3.15.0

* Add basic internal testing for memory allocations.

    *Joel Hawksley*

* Add support for request formats.

    *Joel Hawksley*

* Add `rendered_json` test helper.

    *Joel Hawksley*

* Add `with_format` test helper.

    *Joel Hawksley*

* Warn if using Ruby < 3.2 or Rails < 7.1, which won't be supported by ViewComponent v4, to be released no earlier than April 1, 2025.

    *Joel Hawksley*

* Add Kicksite to list of companies using ViewComponent.

    *Adil Lari*

* Allow overridden slot methods to use `super`.

    *Andrew Schwartz*

* Add Rails engine support to generators.

    *Tomasz Kowalewski*

* Register stats directories with `Rails::CodeStatistics.register_directory` to support `rails stats` in Rails 8.

    *Petrik de Heus*

* Fixed type declaration for `ViewComponent::TestHelpers.with_controller_class` parameter.

    *Graham Rogers*

## 3.14.0

* Defer to built-in caching for language environment setup, rather than manually using `actions/cache` in CI.

    *Simon Fish*

* Add test coverage for use of `turbo_stream` helpers in components when `capture_compatibility_patch_enabled` is `true`.

  *Simon Fish*

* Add experimental `SlotableDefault` module, allowing components to define a `default_SLOTNAME` method to provide a default value for slots.

    *Joel Hawksley*

* Add documentation on rendering ViewComponents outside of the view context.

    *Joel Hawksley*

* Look for preview files that end in `preview.rb` rather than `_preview.rb` to allow previews to exist in sidecar directory with test files.

    *Seth Herr*

* Add `assert_component_rendered` test helper.

    *Reegan Viljoen*

* Add `prefix:` option to `use_helpers`.

    *Reegan Viljoen*

* Add support for Rails 7.2.

    *Reegan Viljoen*

## 3.13.0

* Add ruby head and YJIT to CI.

    *Reegan Viljoen*

* Fixed a bug where inline templates where unable to remove trailing whitespace without throwing an error.

    *Reegan Viljoen*

* Fixed CI for Rails main.

    *Reegan Viljoen*

* Add `from:` option to `use_helpers` to allow for more flexible helper inclusion from modules.

    *Reegan Viljoen*

* Fixed ruby head matcher issue.

    *Reegan Viljoen*

* Fix a bug where component previews would crash with "undefined local variable or method `preview_source`."

    *Henning Koch*

## 3.12.1

* Ensure content is rendered correctly for forwarded slots.

    *Cameron Dutro*

## 3.12.0

* Remove offline links from resources.

    *Paulo Henrique Meneses*

* Fix templates not being correctly populated when caller location label has a prefix.

  On the upstream version of Ruby, method owners are now included in backtraces as prefixes. This caused the call stack filtering to not work as intended and thus `source_location` to be incorrect for child ViewComponents, consequently not populating templates correctly.

    *Allan Pires, Jason Kim*

* Use component path for generating RSpec files.

  When generating new RSpec files for components, the generator will use the `view_component_path` value in the config to decide where to put the new spec file. For instance, if the `view_component_path` option has been changed to `app/views/components`, the generator will put the spec file in `spec/views/components`. **If the `view_component_path` doesn't start with `app/`, then the generator will fall back to `spec/components/`.**

  This feature is enabled via the `config.view_component.generate.use_component_path_for_rspec_tests` option, defaulting to `false`. The default will change to `true` in ViewComponent v4.

    *William Mathewson*

## 3.11.0

* Fix running non-integration tests under Rails main.

    *Cameron Dutro*

* Better name and link for Avo.

    *Adrian Marin*

* Document using rack-mini-profiler with ViewComponent.

    *Thomas Carr*

* Move dependencies to gemspec.

    *Joel Hawksley*

* Include ViewComponent::UseHelpers by default.

    *Reegan Viljoen*

* Bump `puma` in Gemfile.lock.

    *Cameron Dutro*

* Add Keenly to users list.

    *Vinoth*

## 3.10.0

* Fix html escaping in `#call` for non-strings.

    *Reegan Viljoen, Cameron Dutro*

* Add `output_preamble` to match `output_postamble`, using the same safety checks.

    *Kali Donovan, Michael Daross*

* Exclude html escaping of I18n reserved keys with `I18n::RESERVED_KEYS` rather than `I18n.reserved_keys_pattern`.

    *Nick Coyne*

* Update CI configuration to use `Appraisal`.

    *Hans Lemuet, Simon Fish*

## 3.9.0

* Don’t break `rails stats` if ViewComponent path is missing.

    *Claudio Baccigalupo*

* Add deprecation warnings for EOL ruby and Rails versions and patches associated with them.

    *Reegan Viljoen*

* Add support for Ruby 3.3.

    *Reegan Viljoen*

* Allow translations to be inherited and overridden in subclasses.

    *Elia Schito*

* Resolve console warnings when running test suite.

    *Joel Hawksley*

* Fix spelling in a local variable.

    *Olle Jonsson*

* Avoid duplicating rendered string when `output_postamble` is blank.

    *Mitchell Henke*

* Ensure HTML output safety.

    *Cameron Dutro*

## 3.8.0

* Use correct value for the `config.action_dispatch.show_exceptions` config option for edge Rails.

    *Cameron Dutro*

* Remove unsupported versions of Rails & Ruby from CI matrix.

    *Reegan Viljoen*

* Raise error when uncountable slot names are used in `renders_many`

    *Hugo Chantelauze*
    *Reegan Viljoen*

* Replace usage of `String#ends_with?` with `String#end_with?` to reduce the dependency on ActiveSupport core extensions.

    *halo*

* Don't add ActionDispatch::Static middleware unless `public_file_server.enabled`.

    *Daniel Gonzalez*
    *Reegan Viljoen*

* Resolve an issue where slots starting with `call` would cause a `NameError`

    *Blake Williams*

* Add `use_helper` API.

    *Reegan Viljoen*

* Fix bug where the `Rails` module wasn't being searched from the root namespace.

    *Zenéixe*

* Fix bug where `#with_request_url`, set the incorrect `request.fullpath`.

    *Nachiket Pusalkar*

* Allow setting method when using the `with_request_url` test helper.

    *Andrew Duthie*

## 3.7.0

* Support Rails 7.1 in CI.

    *Reegan Viljoen*
    *Cameron Dutro*

* Document the capture compatibility patch on the Known issues page.

    *Simon Fish*

* Add Simundia to list of companies using ViewComponent.

    *Alexandre Ignjatovic*

* Reduce UnboundMethod objects by memoizing initialize_parameters.

    *Rainer Borene*

* Improve docs about inline templates interpolation.

    *Hans Lemuet*

* Update generators.md to clarify the way of changing `config.view_component.view_component_path`.

    *Shozo Hatta*

* Attempt to fix Ferrum timeout errors by creating driver with unique name.

    *Cameron Dutro*

## 3.6.0

* Refer to `helpers` in `NameError` message in development and test environments.

    *Simon Fish*

* Fix API documentation and revert unnecessary change in `preview.rb`.

    *Richard Macklin*

* Initialize ViewComponent::Config with defaults before framework load.

    *Simon Fish*

* Add 3.2 to the list of Ruby CI versions

    *Igor Drozdov*

* Stop running PVC's `docs:preview` rake task in CI, as the old docsite has been removed.

    *Cameron Dutro*

* Minor testing documentation improvement.

    *Travis Gaff*

* Add SearchApi to users list.

    *Sebastjan Prachovskij*

* Fix `#with_request_url` to ensure `request.query_parameters` is an instance of ActiveSupport::HashWithIndifferentAccess.

    *milk1000cc*

* Add PeopleForce to list of companies using ViewComponent.

    *Volodymyr Khandiuk*

## 3.5.0

* Add Skroutz to users list.

    *Chris Nitsas*

* Improve implementation of `#render_parent` so it respects variants and deep inheritance hierarchies.

    *Cameron Dutro*

* Add CharlieHR to users list.

    *Alex Balhatchet*

## 3.4.0

* Avoid including Rails `url_helpers` into `Preview` class when they're not defined.

    *Richard Macklin*

* Allow instrumentation to be automatically included in Server-Timing headers generated by Rails. To enable this set the config `config.use_deprecated_instrumentation_name = false`.  The old key `!render.view_component` is deprecated: update ActiveSupport::Notification subscriptions to `render.view_component`.

    *Travis Gaff*

## 3.3.0

* Include InlineTemplate by default in Base. **Note:** It's no longer necessary to include `ViewComponent::InlineTemplate` to use inline templates.

    *Joel Hawksley*

* Allow Setting host when using the `with_request_url` test helper.

     *Daniel Alfaro*

* Resolve ambiguous preview paths when using components without the Component suffix.

     *Reed Law*

## 3.2.0

* Fix viewcomponent.org Axe violations.

    *Joel Hawksley*

* Fix example of RSpec configuration in docs

    *Pasha Kalashnikov*

* Add URL helpers to previews

    *Reegan Viljoen*

## 3.1.0

* Check `defined?(Rails) && Rails.application` before using `ViewComponent::Base.config.view_component_path`.

    *Donapieppo*

* Allow customization of polymorphic slot setters.

    *Cameron Dutro*

* Fix duplication in configuration docs.

    *Tom Chen*

* Fix helpers not reloading in development.

    *Jonathan del Strother*

* Add `SECURITY.md`.

    *Joel Hawksley*

* Add Ophelos to list of companies using ViewComponent.

    *Graham Rogers*

* Add FlightLogger to list of companies using ViewComponent.

    *Joseph Carpenter*

* Fix coverage reports overwriting each other when running locally.

    *Jonathan del Strother*

* Add @reeganviljoen to triage team.

    *Reegan Viljoen*

### v3.0.0

1,000+ days and 100+ releases later, the 200+ contributors to ViewComponent are proud to ship v3.0.0!

We're so grateful for all the work of community members to get us to this release. Whether it’s filing bug reports, designing APIs in long-winded discussion threads, or writing code itself, ViewComponent is built by the community, for the community. We couldn’t be more proud of what we’re building together :heart:

This release makes the following breaking changes, many of which have long been deprecated:

* BREAKING: Remove deprecated slots setter methods. Use `with_SLOT_NAME` instead.

    *Joel Hawksley*

For example:

```diff
<%= render BlogComponent.new do |component| %>
-  <% component.header do %>
+  <% component.with_header do %>
    <%= link_to "My blog", root_path %>
  <% end %>
<% end %>
```

* BREAKING: Remove deprecated SlotsV1 in favor of current SlotsV2.

    *Joel Hawksley*

* BREAKING: Remove deprecated `content_areas` feature. Use Slots instead.

    *Joel Hawksley*

* BREAKING: Remove deprecated support for loading ViewComponent engine manually. Make sure `require "view_component/engine"` is removed from `Gemfile`.

    *Joel Hawksley*

* BREAKING: Remove deprecated `generate_*` methods. Use `generate.*` instead.

    *Joel Hawksley*

* BREAKING: Remove deprecated `with_variant` method.

    *Joel Hawksley*

* BREAKING: Remove deprecated `rendered_component` in favor of `rendered_content`.

    *Joel Hawksley*

* BREAKING: Remove deprecated `config.preview_path` in favor of `config.preview_paths`.

    *Joel Hawksley*

* BREAKING: Support Ruby 2.7+ instead of 2.4+

    *Joel Hawksley*

* BREAKING: Remove deprecated `before_render_check`.

    *Joel Hawksley*

* BREAKING: Change counter variable to start iterating from `0` instead of `1`.

    *Frank S*

* BREAKING: `#SLOT_NAME` getter no longer accepts arguments. This change was missed as part of the earlier deprecation in `3.0.0.rc1`.

    *Joel Hawksley*

* BREAKING: Raise `TranslateCalledBeforeRenderError`, `ControllerCalledBeforeRenderError`, or `HelpersCalledBeforeRenderError` instead of `ViewContextCalledBeforeRenderError`.

    *Joel Hawksley*

* BREAKING: Raise `SlotPredicateNameError`, `RedefinedSlotError`, `ReservedSingularSlotNameError`, `ContentSlotNameError`, `InvalidSlotDefinitionError`, `ReservedPluralSlotNameError`, `ContentAlreadySetForPolymorphicSlotErrror`, `SystemTestControllerOnlyAllowedInTestError`, `SystemTestControllerNefariousPathError`, `NoMatchingTemplatesForPreviewError`, `MultipleMatchingTemplatesForPreviewError`, `DuplicateContentError`, `EmptyOrInvalidInitializerError`, `MissingCollectionArgumentError`, `ReservedParameterError`, `InvalidCollectionArgumentError`, `MultipleInlineTemplatesError`, `MissingPreviewTemplateError`, `DuplicateSlotContentError` or `NilWithContentError` instead of generic error classes.

    *Joel Hawksley*

* BREAKING: Rename `SlotV2` to `Slot` and `SlotableV2` to `Slotable`.

    *Joel Hawksley*

* BREAKING: Incorporate `PolymorphicSlots` into `Slotable`. To migrate, remove any references to `PolymorphicSlots` as they are no longer necessary.

    *Joel Hawksley*

* BREAKING: Rename private TestHelpers#controller, #build_controller, #request, and #preview_class to avoid conflicts. Note: While these methods were undocumented and marked as private, they were accessible in tests. As such, we're considering this to be a breaking change.

    *Joel Hawksley*

* Add support for CSP nonces inside of components.

      *Reegan Viljoen*

### v3.0.0.rc6

Run into an issue with this release candidate? [Let us know](https://github.com/ViewComponent/view_component/issues/1629). We hope to release v3.0.0 in the near future!

* BREAKING: `#SLOT_NAME` getter no longer accepts arguments. This change was missed as part of the earlier deprecation in `3.0.0.rc1`.

    *Joel Hawksley*

* BREAKING: Raise `TranslateCalledBeforeRenderError`, `ControllerCalledBeforeRenderError`, or `HelpersCalledBeforeRenderError` instead of `ViewContextCalledBeforeRenderError`.

    *Joel Hawksley*

* BREAKING: Raise `SlotPredicateNameError`, `RedefinedSlotError`, `ReservedSingularSlotNameError`, `ContentSlotNameError`, `InvalidSlotDefinitionError`, `ReservedPluralSlotNameError`, `ContentAlreadySetForPolymorphicSlotErrror`, `SystemTestControllerOnlyAllowedInTestError`, `SystemTestControllerNefariousPathError`, `NoMatchingTemplatesForPreviewError`, `MultipleMatchingTemplatesForPreviewError`, `DuplicateContentError`, `EmptyOrInvalidInitializerError`, `MissingCollectionArgumentError`, `ReservedParameterError`, `InvalidCollectionArgumentError`, `MultipleInlineTemplatesError`, `MissingPreviewTemplateError`, `DuplicateSlotContentError` or `NilWithContentError` instead of generic error classes.

    *Joel Hawksley*

* Fix bug where `content?` and `with_content` didn't work reliably with slots.

    *Derek Kniffin, Joel Hawksley*

* Add `with_SLOT_NAME_content` helper.

    *Will Cosgrove*

* Allow ActiveRecord objects to be passed to `renders_many`.

    *Leigh Halliday*

* Fix broken links in documentation.

    *Ellen Keal*

* Run `standardrb` against markdown in docs.

    *Joel Hawksley*

* Allow `.with_content` to be redefined by components.

    *Joel Hawksley*

* Run `standardrb` against markdown in docs.

    *Joel Hawksley*

* Raise error if translations are used in initializer.

    *Joel Hawksley*

## v3.0.0.rc5

Run into an issue with this release candidate? [Let us know](https://github.com/ViewComponent/view_component/issues/1629).

* Fix bug where `mkdir_p` failed due to incorrect permissions.

    *Joel Hawksley*

* Check for inline `erb_template` calls when deciding whether to compile a component's superclass.

    *Justin Kenyon*

* Protect against `SystemStackError` if `CaptureCompatibility` module is included more than once.

    *Cameron Dutro*

## v3.0.0.rc4

Run into an issue with this release candidate? [Let us know](https://github.com/ViewComponent/view_component/issues/1629).

* Add `TestHelpers#vc_test_request`.

    *Joel Hawksley*

## v3.0.0.rc3

Run into an issue with this release candidate? [Let us know](https://github.com/ViewComponent/view_component/issues/1629).

* Fix typos in generator docs.

    *Sascha Karnatz*

* Add `TestHelpers#vc_test_controller`.

    *Joel Hawksley*

* Document `config.view_component.capture_compatibility_patch_enabled` as option for the known incompatibilities with Rails form helpers.

    *Tobias L. Maier*

* Add support for experimental inline templates.

    *Blake Williams*

* Expose `translate` and `t` I18n methods on component classes.

    *Elia Schito*

* Protect against Arbitrary File Read edge case in `ViewComponentsSystemTestController`.

    *Nick Malcolm*

## v3.0.0.rc2

Run into an issue with this release? [Let us know](https://github.com/ViewComponent/view_component/issues/1629).

* BREAKING: Rename `SlotV2` to `Slot` and `SlotableV2` to `Slotable`.

    *Joel Hawksley*

* BREAKING: Incorporate `PolymorphicSlots` into `Slotable`. To migrate, remove any references to `PolymorphicSlots` as they are no longer necessary.

    *Joel Hawksley*

* BREAKING: Rename private TestHelpers#controller, #build_controller, #request, and #preview_class to avoid conflicts. Note: While these methods were undocumented and marked as private, they were accessible in tests. As such, we're considering this to be a breaking change.

    *Joel Hawksley*

* Avoid loading ActionView::Base during Rails initialization. Originally submitted in #1528.

    *Jonathan del Strother*

* Improve documentation of known incompatibilities with Rails form helpers.

    *Tobias L. Maier*

* Remove dependency on environment task from `view_component:statsetup`.

    *Svetlin Simonyan*

* Add experimental `config.view_component.capture_compatibility_patch_enabled` option resolving rendering issues related to forms, capture, turbo frames, etc.

    *Blake Williams*

* Add `#content?` method that indicates if content has been passed to component.

    *Joel Hawksley*

* Added example of a custom preview controller.

    *Graham Rogers*

* Add Krystal to list of companies using ViewComponent.

     *Matt Bearman*

* Add Mon Ami to list of companies using ViewComponent.

    *Ethan Lee-Tyson*

## 3.0.0.rc1

1,000+ days and 100+ releases later, the 200+ contributors to ViewComponent are proud to ship v3.0.0!

We're so grateful for all the work of community members to get us to this release. Whether it’s filing bug reports, designing APIs in long-winded discussion threads, or writing code itself, ViewComponent is built by the community, for the community. We couldn’t be more proud of what we’re building together :heart:

This release makes the following breaking changes, many of which have long been deprecated:

* BREAKING: Remove deprecated slots setter methods. Use `with_SLOT_NAME` instead.

    *Joel Hawksley*

* BREAKING: Remove deprecated SlotsV1 in favor of current SlotsV2.

    *Joel Hawksley*

* BREAKING: Remove deprecated `content_areas` feature. Use Slots instead.

    *Joel Hawksley*

* BREAKING: Remove deprecated support for loading ViewComponent engine manually. Make sure `require "view_component/engine"` is removed from `Gemfile`.

    *Joel Hawksley*

* BREAKING: Remove deprecated `generate_*` methods. Use `generate.*` instead.

    *Joel Hawksley*

* BREAKING: Remove deprecated `with_variant` method.

    *Joel Hawksley*

* BREAKING: Remove deprecated `rendered_component` in favor of `rendered_content`.

    *Joel Hawksley*

* BREAKING: Remove deprecated `config.preview_path` in favor of `config.preview_paths`.

    *Joel Hawksley*

* BREAKING: Support Ruby 2.7+ instead of 2.4+

    *Joel Hawksley*

* BREAKING: Remove deprecated `before_render_check`.

    *Joel Hawksley*

* BREAKING: Change counter variable to start iterating from `0` instead of `1`.

    *Frank S*

Run into an issue with this release? [Let us know](https://github.com/ViewComponent/view_component/issues/1629).

## 2.82.0

* Revert "Avoid loading ActionView::Base during initialization (#1528)"

    *Jon Rohan*

* Fix tests using `with_rendered_component_path` with custom layouts.

    *Ian Hollander*

## 2.81.0

* Adjust the way response objects are set on the preview controller to work around a recent change in Rails main.

    *Cameron Dutro*

* Fix typo in "Generate a Stimulus controller" documentation.

    *Ben Trewern*

* Modify the `render_in_view_context` test helper to forward its args to the block.

    *Cameron Dutro*

## 2.80.0

* Move system test endpoint out of the unrelated previews controller.

    *Edwin Mak*

* Display Ruby 2.7 deprecation notice only once, when starting the application.

    *Henrik Hauge Bjørnskov*

* Require Rails 5.2+ in gemspec and update documentation.

    *Drew Bragg*

* Add documentation for using `with_rendered_component_path` with RSpec.

    *Edwin Mak*

## 2.79.0

* Add ability to pass explicit `preview_path` to preview generator.

    *Erinna Chen*

* Add `with_rendered_component_path` helper for writing component system tests.

    *Edwin Mak*

* Include gem name and deprecation horizon in every deprecation message.

    *Jan Klimo*

## 2.78.0

* Support variants with dots in their names.

    *Javi Martín*

## 2.77.0

* Support variants with dashes in their names.

    *Javi Martín*

## 2.76.0

* `Component.with_collection` supports components that accept splatted keyword arguments.

    *Zee Spencer*

* Remove `config.view_component.use_consistent_rendering_lifecycle` since it is no longer planned for 3.0.

    *Blake Williams*

* Prevent polymorphic slots from calculating `content` when setting a slot.

    *Blake Williams*

* Add ability to pass in the preview class to `render_preview`.

    *Jon Rohan*

* Fix issue causing PVC tests to fail in CI.

    *Cameron Dutro*

* Fix YARD docs build task.

    *Hans Lemuet*

* Add Startup Jobs to list of companies using ViewComponent.

    *Marc Köhlbrugge*

* Run PVC's accessibility tests in a single process to avoid resource contention in CI.

    *Cameron Dutro*

## 2.75.0

* Avoid loading ActionView::Base during Rails initialization.

    *Jonathan del Strother*

<!-- vale off -->
* Mention lambda slots rendering returned values lazily in the guide.

    *Graham Rogers*
<!-- vale on -->

* Add "ViewComponent In The Wild" articles to resources.

    *Alexander Baygeldin*

## 2.74.1

* Add more users of ViewComponent to docs.

    *Joel Hawksley*

* Add a known issue for usage with `turbo_frame_tag` to the documentation.

    *Vlad Radulescu*

* Add note about system testing components with previews.

    *Joel Hawksley*

* Remove locking mechanisms from the compiler.

    *Cameron Dutro*

## 2.74.0

* Add Avo to list of companies using ViewComponent.

    *Adrian Marin*

* Promote experimental `_output_postamble` method to public API as `output_postamble`.

    *Joel Hawksley*

* Promote experimental `_sidecar_files` method to public API as `sidecar_files`.

    *Joel Hawksley*

* Fix `show_previews` regression introduced in 2.73.0.

    *Andy Baranov*

* `with_request_url` test helper supports router constraints (such as Devise).

     *Aotokitsuruya*

## 2.73.0

* Remove experimental `_after_compile` lifecycle method.

    *Joel Hawksley*

* Fix capitalization of JavaScript in docs.

    *Erinna Chen*

* Add PrintReleaf to list of companies using ViewComponent.

    *Ry Kulp*

* Simplify CI configuration to a single build per Ruby/Rails version.

    *Joel Hawksley*

* Correctly document `generate.sidecar` config option.

    *Ruben Smit*

* Add Yobbers to list of companies using ViewComponent.

    *Anton Prins*

## 2.72.0

* Deprecate support for Ruby < 2.7 for removal in v3.0.0.

    *Joel Hawksley*

* Add `changelog_uri` to gemspec.

    *Joel Hawksley*

* Link to `CHANGELOG.md` instead of symlink.

    *Joel Hawksley.

* Add Aluuno to list of companies using ViewComponent.

    *Daniel Naves de Carvalho*

* Add `source_code_uri` to gemspec.

    *Yoshiyuki Hirano*

* Update link to benchmark script in docs.

    *Daniel Diekmeier*

* Add special exception message for `renders_one :content` explaining that content passed as a block will be assigned to the `content` accessor without having to create an explicit slot.

    *Daniel Diekmeier*

## 2.71.0

**ViewComponent has moved to a new organization: [https://github.com/viewcomponent/view_component](https://github.com/viewcomponent/view_component). See [https://github.com/viewcomponent/view_component/issues/1424](https://github.com/viewcomponent/view_component/issues/1424) for more details.**

## 2.70.0

* `render_preview` can pass parameters to preview.

    *Joel Hawksley*

* Fix docs typos.

    *Joel Hawksley*

* Add architectural decisions to documentation and rename sidebar sections.

    *Joel Hawksley*

* Clarify documentation on testability of Rails views.

    *Joel Hawksley*

* Add Arrows to list of companies using ViewComponent.

    *Matt Swanson*

* Add WIP to list of companies using ViewComponent.

    *Marc Köhlbrugge*

* Update slots documentation to include how to reference slots.

    *Brittany Ellich*

* Add Clio to list of companies using ViewComponent.

    *Mike Buckley*

## 2.69.0

* Add missing `require` to fix `pvc` build.

    *Joel Hawksley*

* Add `config.view_component.use_consistent_rendering_lifecycle` to ensure side-effects in `content` are consistently evaluated before components are rendered. This change effectively means that `content` is evaluated for every component render where `render?` returns true. As a result, code that's passed to a component via a block/content will now always be evaluated, before `#call`, which can reveal bugs in existing components. This configuration option defaults to `false` but will be enabled in 3.0 and the old behavior will be removed.

    *Blake Williams*

* Update Prism to version 1.28.0.

    *Thomas Hutterer*

* Corrects the deprecation warning for named slots to show the file and line where the slot is called.

    *River Bailey*

## 2.68.0

* Update `gemspec` author to be ViewComponent team.

    *Joel Hawksley*

* Fix bug where `ViewComponent::Compiler` wasn't required.

    *Joel Hawksley*

## 2.67.0

* Use ViewComponent::Base.config as the internal endpoint for config.

    *Simon Fish*

* Fix bug where `#with_request_url`, when used with query string, set the incorrect `request.path` and `request.fullpath`.

    *Franz Liedke*

* Add link to [ViewComponentAttributes](https://github.com/amba-Health/view_component_attributes) in Resources section of docs.

    *Romaric Pascal*

* `render_preview` test helper is available by default. It is no longer necessary to include `ViewComponent::RenderPreviewHelper`.

    *Joel Hawksley*

## 2.66.0

* Add missing `generate.sidecar`, `generate.stimulus_controller`, `generate.locale`, `generate.distinct_locale_files`, `generate.preview` config options to `config.view_component`.

    *Simon Fish*

## 2.65.0

* Raise `ArgumentError` when conflicting Slots are defined.

    Before this change it was possible to define Slots with conflicting names, for example:

    ```ruby
    class MyComponent < ViewComponent::Base
      renders_one :item
      renders_many :items
    end
    ```

    *Joel Hawksley*

## 2.64.0

* Add `warn_on_deprecated_slot_setter` flag to opt-in to deprecation warning.

    In [v2.54.0](https://viewcomponent.org/CHANGELOG.html#2540), the Slots API was updated to require the `with_*` prefix for setting Slots. The non-`with_*` setters will be deprecated in a coming version and removed in `v3.0`.

    To enable the coming deprecation warning, add `warn_on_deprecated_slot_setter`:

    ```ruby
    class DeprecatedSlotsSetterComponent < ViewComponent::Base
      warn_on_deprecated_slot_setter
    end
    ```

    *Joel Hawksley*

* Add [`m`](https://rubygems.org/gems/m) to development environment.

    *Joel Hawksley*

* Fix potential deadlock scenario in the compiler's development mode.

    *Blake Williams*

## 2.63.0

* Fixed typo in `renders_many` documentation.

    *Graham Rogers*

* Add documentation about working with `turbo-rails`.

    *Matheus Poli Camilo*

* Fix issue causing helper methods to not be available in nested components when the render monkey patch is disabled and `render_component` is used.

    *Daniel Scheffknecht*

## 2.62.0

* Remove the experimental global output buffer feature.
* Restore functionality that used to attempt to compile templates on each call to `#render_in`.
* Un-pin `rails` `main` dependency.

    *Cameron Dutro*

* Add blank space between "in" and "ViewComponent" in a deprecation warning.

    *Vikram Dighe*

* Add HappyCo to list of companies using ViewComponent.

    *Josh Clayton*

* Add predicate method support to polymorphic slots.

    *Graham Rogers*

## 2.61.1

* Revert `Expose Capybara DSL methods directly inside tests.` This change unintentionally broke other Capybara methods and thus introduced a regression. We aren't confident that we can fail forward so we have decided to revert this change.

    *Joel Hawksley, Blake Williams*

* Revert change making content evaluation consistent.

    *Blake Williams*

* Pin `rails` `main` dependency due to incompatibility with Global Output Buffer.

    *Joel Hawksley*

## 2.61.0

* Ensure side-effects in `content` are consistently evaluated before components are rendered. This change effectively means that `content` is evaluated for every component render where `render?` returns true. As a result, code that is passed to a component via a block/content will now always be evaluated, before `#call`, which can reveal bugs in existing components.

    *Blake Williams*

## 2.60.0

* Add support for `render_preview` in RSpec tests.

    *Thomas Hutterer*

## 2.59.0

* Expose Capybara DSL methods directly inside tests.

    The following Capybara methods are now available directly without having to use the `page` method:

  * [`all`](https://rubydoc.info/github/teamcapybara/capybara/Capybara%2FNode%2FFinders:all)
  * [`first`](https://rubydoc.info/github/teamcapybara/capybara/Capybara%2FNode%2FFinders:first)
  * [`text`](https://rubydoc.info/github/teamcapybara/capybara/Capybara%2FNode%2FSimple:text)
  * [`find`](https://rubydoc.info/github/teamcapybara/capybara/master/Capybara%2FNode%2FFinders:find)
  * [`find_all`](https://rubydoc.info/github/teamcapybara/capybara/master/Capybara%2FNode%2FFinders:find_all)
  * [`find_button`](https://rubydoc.info/github/teamcapybara/capybara/master/Capybara%2FNode%2FFinders:find_button)
  * [`find_by_id`](https://rubydoc.info/github/teamcapybara/capybara/master/Capybara%2FNode%2FFinders:find_by_id)
  * [`find_field`](https://rubydoc.info/github/teamcapybara/capybara/master/Capybara%2FNode%2FFinders:find_field)
  * [`find_link`](https://rubydoc.info/github/teamcapybara/capybara/master/Capybara%2FNode%2FFinders:find_link)
  * [`has_content?`](https://rubydoc.info/github/teamcapybara/capybara/master/Capybara%2FNode%2FMatchers:has_content%3F)
  * [`has_text?`](https://rubydoc.info/github/teamcapybara/capybara/master/Capybara%2FNode%2FMatchers:has_text%3F)
  * [`has_css?`](https://rubydoc.info/github/teamcapybara/capybara/master/Capybara%2FNode%2FMatchers:has_css%3F)
  * [`has_no_content?`](https://rubydoc.info/github/teamcapybara/capybara/master/Capybara%2FNode%2FMatchers:has_no_content%3F)
  * [`has_no_text?`](https://rubydoc.info/github/teamcapybara/capybara/master/Capybara%2FNode%2FMatchers:has_no_text%3F)
  * [`has_no_css?`](https://rubydoc.info/github/teamcapybara/capybara/master/Capybara%2FNode%2FMatchers:has_no_css%3F)
  * [`has_no_xpath?`](https://rubydoc.info/github/teamcapybara/capybara/master/Capybara%2FNode%2FMatchers:has_no_xpath%3F)
  * [`has_xpath?`](https://rubydoc.info/github/teamcapybara/capybara/master/Capybara%2FNode%2FMatchers:has_xpath%3F)
  * [`has_link?`](https://rubydoc.info/github/teamcapybara/capybara/master/Capybara%2FNode%2FMatchers:has_link%3F)
  * [`has_no_link?`](https://rubydoc.info/github/teamcapybara/capybara/master/Capybara%2FNode%2FMatchers:has_no_link%3F)
  * [`has_button?`](https://rubydoc.info/github/teamcapybara/capybara/master/Capybara%2FNode%2FMatchers:has_button%3F)
  * [`has_no_button?`](https://rubydoc.info/github/teamcapybara/capybara/master/Capybara%2FNode%2FMatchers:has_no_button%3F)
  * [`has_field?`](https://rubydoc.info/github/teamcapybara/capybara/master/Capybara%2FNode%2FMatchers:has_field%3F)
  * [`has_no_field?`](https://rubydoc.info/github/teamcapybara/capybara/master/Capybara%2FNode%2FMatchers:has_no_field%3F)
  * [`has_checked_field?`](https://rubydoc.info/github/teamcapybara/capybara/master/Capybara%2FNode%2FMatchers:has_checked_field%3F)
  * [`has_unchecked_field?`](https://rubydoc.info/github/teamcapybara/capybara/master/Capybara%2FNode%2FMatchers:has_unchecked_field%3F)
  * [`has_no_table?`](https://rubydoc.info/github/teamcapybara/capybara/master/Capybara%2FNode%2FMatchers:has_no_table%3F)
  * [`has_table?`](https://rubydoc.info/github/teamcapybara/capybara/master/Capybara%2FNode%2FMatchers:has_table%3F)
  * [`has_select?`](https://rubydoc.info/github/teamcapybara/capybara/master/Capybara%2FNode%2FMatchers:has_select%3F)
  * [`has_no_select?`](https://rubydoc.info/github/teamcapybara/capybara/master/Capybara%2FNode%2FMatchers:has_no_select%3F)
  * [`has_selector?`](https://rubydoc.info/github/teamcapybara/capybara/master/Capybara%2FNode%2FMatchers:has_selector%3F)
  * [`has_no_selector?`](https://rubydoc.info/github/teamcapybara/capybara/master/Capybara%2FNode%2FMatchers:has_no_selector%3F)
  * [`has_no_checked_field?`](https://rubydoc.info/github/teamcapybara/capybara/master/Capybara%2FNode%2FMatchers:has_no_checked_field%3F)
  * [`has_no_unchecked_field?`](https://rubydoc.info/github/teamcapybara/capybara/master/Capybara%2FNode%2FMatchers:has_no_unchecked_field%3F)

* Add support for `within*` Capybara DLS methods:

  * [`within`](https://rubydoc.info/github/teamcapybara/capybara/master/Capybara%2FSession:within)
  * [`within_element`](https://rubydoc.info/github/teamcapybara/capybara/master/Capybara%2FSession:within)
  * [`within_fieldset`](https://rubydoc.info/github/teamcapybara/capybara/master/Capybara%2FSession:within_fieldset)
  * [`within_table`](https://rubydoc.info/github/teamcapybara/capybara/master/Capybara%2FSession:within_table)

    *Jacob Carlborg*

## 2.58.0

* Switch to `standardrb`.

    *Joel Hawksley*

* Add BootrAils article to resources.

    *Joel Hawksley*

* Add @boardfish and @spone as maintainers.

    *Joel Hawksley, Cameron Dutro, Blake Williams*

* Re-compile updated, inherited templates when class caching is disabled.

    *Patrick Arnett*

* Add the latest version to the docs index.
* Improve the docs: add the versions various features were introduced in.

    *Hans Lemuet*

* Update docs to reflect lack of block content support in controllers.

    *Joel Hawksley*

* Prevent adding duplicates to `autoload_paths`.

    *Thomas Hutterer*

* Add FreeAgent to list of companies using ViewComponent.

    *Simon Fish*

* Include polymorphic slots in `ViewComponent::Base` by default.

    *Cameron Dutro*

* Add per-component config option for stripping newlines from templates before compilation.

    *Cameron Dutro*

* Add link to article by Matouš Borák.

    *Joel Hawksley*

## 2.57.1

* Fix issue causing `NoMethodError`s when calling helper methods from components rendered as part of a collection.
* Fix syntax error in the ERB example in the polymorphic slots docs.

    *Cameron Dutro*

## 2.57.0

* Add missing `require` for `Translatable` module in `Base`.

    *Hans Lemuet*

* Allow anything that responds to `#render_in` to be rendered in the parent component's view context.

    *Cameron Dutro*

* Fix script/release so it honors semver.

    *Cameron Dutro*

## 2.56.2

* Restore removed `rendered_component`, marking it for deprecation in v3.0.0.

    *Tyson Gach, Richard Macklin, Joel Hawksley*

## 2.56.1

* Rename private accessor `rendered_component` to `rendered_content`.

    *Yoshiyuki Hirano, Simon Dawson*

## 2.56.0

* Introduce experimental `render_preview` test helper. Note: `@rendered_component` in `TestHelpers` has been renamed to `@rendered_content`.

    *Joel Hawksley*

* Move framework tests into sandbox application.

    *Joel Hawksley*

* Add G2 to list of companies that use ViewComponent.

    *Jack Shuff*

* Add Within3 to list of companies that use ViewComponent.

    *Drew Bragg*

* Add Mission Met to list of companies that use ViewComponent.

    *Nick Smith*

* Fix `#with_request_url` test helper not parsing nested query parameters into nested hashes.

    *Richard Marbach*

## 2.55.0

* Add `render_parent` convenience method to avoid confusion between `<%= super %>` and `<% super %>` in template code.

    *Cameron Dutro*

* Add note about discouraging inheritance.

    *Joel Hawksley*

* Clean up grammar in documentation.

    *Joel Hawksley*

* The ViewComponent team at GitHub is hiring! We're looking for a Rails engineer with accessibility experience: [https://boards.greenhouse.io/github/jobs/4020166](https://boards.greenhouse.io/github/jobs/4020166). Reach out to joelhawksley@github.com with any questions!

* The ViewComponent team is hosting a happy hour at RailsConf. Join us for snacks, drinks, and stickers: [https://www.eventbrite.com/e/viewcomponent-happy-hour-tickets-304168585427](https://www.eventbrite.com/e/viewcomponent-happy-hour-tickets-304168585427)

## 2.54.1

* Update docs dependencies.

    *Joel Hawksley*

* Resolve warning in slots API.
* Raise in the test environment when ViewComponent code emits a warning.

    *Blake Williams*

## 2.54.0

* Add `with_*` slot API for defining slots. Note: we plan to deprecate the non `with_*` API for slots in an upcoming release.

    *Blake Williams*

* Add QuickNode to list of companies that use ViewComponent.

    *Luc Castera*

* Include the `Translatable` module by default.

    *Elia Schito*

* Update docs dependencies.

    *Joel Hawksley*

## 2.53.0

* Add support for relative I18n scopes to translations.

    *Elia Schito*

* Update CI configuration to use latest Rails 7.0.

    *Hans Lemuet*

* Document how to use blocks with lambda slots.

    *Sam Partington*

* Skip Rails 5.2 in local test environment if using incompatible Ruby version.

    *Cameron Dutro, Blake Williams, Joel Hawksley*

* Improve landing page documentation.

    *Jason Swett*

* Add Bearer to list of companies that use ViewComponent.

    *Yaroslav Shmarov*

* Add articles to resources page.

    *Joel Hawksley*

* Enable rendering arbitrary block contents in the view context in tests.

    *Cameron Dutro*

## 2.52.0

* Add ADR for separate slot getter/setter API.

    *Blake Williams*

* Add the option to use a "global" output buffer so `form_for` and friends can be used with view components.

    *Cameron Dutro, Blake Williams*

* Fix fragment caching in partials when global output buffer is enabled.
* Fix template inheritance when eager loading is disabled.

    *Cameron Dutro*

## 2.51.0

* Update the docs only when releasing a new version.

    *Hans Lemuet*

* Alphabetize companies using ViewComponent and add Brightline to the list.

    *Jack Schuss*

* Add CMYK value for ViewComponent Red color on logo page.

    *Dylan Smith*

* Improve performance by moving template compilation from `#render_in` to `#render_template_for`.

    *Cameron Dutro*

## 2.50.0

* Add tests for `layout` usage when rendering via controller.

    *Felipe Sateler*

* Support returning Arrays from i18n files, and support marking them as HTML-safe translations.

    *foca*

* Add Cometeer and Framework to users list.

    *Elia Schito*

* Update Microsoft Vale styles.

    *Simon Fish*

* Fix example in testing guide for how to setup default Rails tests.

    *Steven Hansen*

* Update benchmark script to render multiple components/partials instead of a single instance per-run.

    *Blake Williams*

* Add predicate methods `#{slot_name}?` to slots.

    *Hans Lemuet*

* Use a dedicated deprecation instance, silence it while testing.

    *Max Beizer, Hans Lemuet, Elia Schito*

* Fix Ruby warnings.

    *Hans Lemuet*

* Place all generator options under `config.generate` namespace.

    *Simon Fish*

* Allow preview generator to use provided component attributes.
* Add config option `config.view_component.generate.preview` to enable project-wide preview generation.
* Ensure all generated `.rb` files include `# frozen_string_literal: true` statement.

    *Bob Maerten*

* Add Shogun to users list.

    *Bernie Chiu*

## 2.49.1

* Patch XSS vulnerability in `ViewComponent::Translatable` module caused by improperly escaped interpolation arguments.

    *Cameron Dutro*

## 2.49.0

* Fix path handling for evaluated view components that broke in Ruby 3.1.

    *Adam Hess*

* Fix support for the `default:` option for a global translation.

    *Elia Schito*

* Ensure i18n scope is a symbol to protect lookups.

    *Simon Fish*

* Small update to preview docs to include rspec mention.

    *Leigh Halliday*

* Small improvements to collection iteration docs.

    *Brian O'Rourke*

* Add good and bad examples to `ViewComponents in practice`.

    *Joel Hawksley*

* Add Ruby 3.1 and Rails 7.0 to CI.

    *Peter Goldstein*

* Move preview logic to module for easier app integration.

    *Sammy Henningsson*

## 2.48.0

* Correct path in example test command in Contributing docs.

    *Mark Wilkinson*

* Update link to GOV.UK Components library in the resources list.

    *Peter Yates*

* Add Lookbook to Resources docs page.

    *Mark Perkins*

* Add blocking compiler mode for use in Rails development and testing modes, improving thread safety.

    *Horia Radu*

* Add generators to support `tailwindcss-rails`.

    *Dino Maric, Hans Lemuet*

* Add a namespaced component example to docs.

    *Hans Lemuet*

* Setup `Appraisal` to add flexibility when testing ViewComponent against multiple Rails versions.

    *Hans Lemuet*

* Return correct values for `request.path` and `request.query_string` methods when using the `with_request_url` test helper.

    *Vasiliy Matyushin*

* Improve style in generators docs.

    *Hans Lemuet*

* Correctly type Ruby version strings and update Rails versions used in CI configuration.

    *Hans Lemuet*

* Make `ViewComponent::Collection` act like a collection of view components.

    *Sammy Henningsson*

* Update `@param` of `#render_inline` to include `ViewComponent::Collection`.

    *Yutaka Kamei*

* Add Wecasa to users list.

    *Mohamed Ziata*

## 2.47.0

* Display preview source on previews that exclusively use templates.

    *Edwin Mak*

* Add a test to ensure trailing newlines are stripped when rendering with `#render_in`.

    *Simon Fish*

* Add WEBrick as a depenency to the application.

    *Connor McQuillan*

* Update Ruby version in `.tool-versions`.

    *Connor McQuillan*

* Add a test to ensure blocks can be passed into lambda slots without the need for any other arguments.

    *Simon Fish*

* Add linters for file consistency.

    *Simon Fish*

* Add @boardfish to docs/index.md and sort contributors.

    *Simon Fish*

* Set up Codespaces for bug replication.

    *Simon Fish*

* Add instructions for replicating bugs and failures.

    *Simon Fish*

* Make @boardfish a committer.

    *Joel Hawksley*

* Validate collection parameter with Active Model attribute names.

    *Simon Fish*

* Fix `helpers` not working with component slots when rendered more than 2 component levels deep.

    *Blake Williams*

* Update ruby to the latest versions

    *Pedro Paiva*

* Fix `vale` linter config options.

    *Hans Lemuet*

* Improve Contributing docs to include how to run tests for a specific version on Rails.

    *Hans Lemuet*

* Add failing test for default form builder and documentation around known issue.

    *Simon Fish*

* Add `--locale` flag to the component generator. Generates as many locale files as defined in `I18n.available_locales`, alongside the component.
* Add config option `config.view_component.generate_locale` to enable project-wide locale generation.
* Add config option `config.view_component.generate_distinct_locale_files` to enable project-wide per-locale translations file generation.

    *Bob Maerten*

* Add config option `config.view_component.generate_sidecar` to always generate in the sidecar directory.

    *Gleydson Tavares*

## 2.46.0

* Add thread safety to the compiler.

    *Horia Radu*

* Add theme-specific logo images to readme.

    *Dylan Smith*

* Add Orbit to users list.

    *Nicolas Goutay*

* Increase clarity around purpose and use of slots.

    *Simon Fish*

* Deprecate loading `view_component/engine` directly.

  **Upgrade notice**: You should update your `Gemfile` like this:

  ```diff
  - gem "view_component", require: "view_component/engine"`
  + gem "view_component"
  ```

    *Yoshiyuki Hirano*

## 2.45.0

* Remove internal APIs from API documentation, fix link to license.

    *Joel Hawksley*

* Add @yhirano55 to triage team.

    *Joel Hawksley*

* Correct a typo in the sample slots code.

    *Simon Fish*

* Add note about `allowed_queries`.

    *Joel Hawksley*

* Add `vale` content linter.

    *Joel Hawksley*

* Remove `require "rails/generators/test_case"` in generator tests.

    *Yoshiyuki Hirano*

* Suppress zeitwerk warning about circular require.

    *Yoshiyuki Hirano*

* Move `test_unit_generator_test.rb` from `test/view_component/` to `test/generators/`.

    *Yoshiyuki Hirano*

* Unify test code of `TestUnitGeneratorTest` with the other generators tests.

    *Yoshiyuki Hirano*

## 2.44.0

* Rename internal accessor to use private naming.

    *Joel Hawksley, Blake Williams, Cameron Dutro*

* Add Github repo link to docs website header.

    *Hans Lemuet*

* Change logo in README for dark theme readability.

    *Dylan Smith*

* Add Litmus to users list.

    *Dylan Smith*

* Add @dylanatsmith as codeowner of the ViewComponent logo and member of committers team.

    *Joel Hawksley*

* Autoload `CompileCache`, which is optionally called in `engine.rb`.

    *Gregory Igelmund*

* Move frequently asked questions to other pages, add History page.

    *Joel Hawksley*

* Fix typo.

    *James Hart*

* Add `require "method_source"` if it options.show_previews_source is enabled.

    *Yoshiyuki Hirano*

* Move show_previews_source definition to Previewable.

    *Yoshiyuki Hirano*

* Clear cache in MethodSource to apply the change odf preview code without app server restart.

    *Yoshiyuki Hirano*

## 2.43.1

* Remove unnecessary call to `ruby2_keywords` for polymorphic slot getters.

    *Cameron Dutro*

## 2.43.0

* Add note about tests and instance methods.

    *Joel Hawksley*

* Flesh out `ViewComponents in practice`.

    *Joel Hawksley*

* Add CODEOWNERS entries for feature areas owned by community committers.

    *Joel Hawksley*

* Separate lint and CI workflows.

    *Blake Williams*

* Add support for `image_path` helper in previews.

    *Tobias Ahlin, Joel Hawksley*

* Add section to docs listing users of ViewComponent. Please submit a PR to add your team to the list!

    *Joel Hawksley*

* Fix loading issue with Stimulus generator and add specs for Stimulus generator.

    *Peter Sumskas*

* Remove dependency on `ActionDispatch::Static` in Rails middleware stack when enabling statics assets for source code preview.

    *Gregory Igelmund*

* Require `view_component/engine` automatically.

    *Cameron Dutro*

## 2.42.0

* Add logo files and page to docs.

    *Dylan Smith*

* Add `ViewComponents in practice` documentation.

    *Joel Hawksley*

* Fix bug where calling lambda slots without arguments would break in Ruby < 2.7.

    *Manuel Puyol*

* Improve Stimulus controller template to import from `stimulus` or `@hotwired/stimulus`.

    *Mario Schüttel*

* Fix bug where `helpers` would instantiate and use a new `view_context` in each component.

    *Blake Williams, Ian C. Anderson*

* Implement polymorphic slots as experimental feature. See the Slots documentation to learn more.

    *Cameron Dutro*

## 2.41.0

* Add `sprockets-rails` development dependency to fix test suite failures when using rails@main.

    *Blake Williams*

* Fix Ruby indentation warning.

    *Blake Williams*

* Add `--parent` generator option to specify the parent class.
* Add config option `config.view_component.component_parent_class` to change it project-wide.

    *Hans Lemuet*

* Update docs to add example for using Devise helpers in tests.

    *Matthew Rider*

* Fix bug where `with_collection_parameter` didn't inherit from parent component.

    *Will Drexler, Christian Campoli*

* Allow query parameters in `with_request_url` test helper.

    *Javi Martín*

* Add "how to render a component to a string" to FAQ.

    *Hans Lemuet*

* Add `#render_in` to API docs.

    *Hans Lemuet*

* Forward keyword arguments from slot wrapper to component instance using ruby2_keywords.

    *Cameron Dutro*

## 2.40.0

* Replace antipatterns section in the documentation with best practices.

    *Blake Williams*

* Add components to `rails stats` task.

    *Nicolas Brousse*

* Fix bug when using Slim and writing a slot whose block evaluates to `nil`.

    *Yousuf Jukaku*

* Add documentation for test helpers.

    *Joel Hawksley*

## 2.39.0

* Clarify documentation of `with_variant` as an override of Action Pack.

    *Blake Williams, Cameron Dutro, Joel Hawksley*

* Update docs page to be called Javascript and CSS, rename Building ViewComponents to Guide.

    *Joel Hawksley*

* Deprecate `Base#with_variant`.

    *Cameron Dutro*

* Error out in the CI if docs/api.md has to be regenerated.

    *Dany Marcoux*

## 2.38.0

* Add `--stimulus` flag to the component generator. Generates a Stimulus controller alongside the component.
* Add config option `config.view_component.generate_stimulus_controller` to always generate a Stimulus controller.

    *Sebastien Auriault*

## 2.37.0

* Clarify slots example in docs to reduce naming confusion.

    *Joel Hawksley, Blake Williams*

* Fix error in documentation for `render_many` passthrough slots.

    *Ollie Nye*

* Add test case for conflict with internal `@variant` variable.

    *David Backeus*

* Document decision to not change naming convention recommendation to remove `-Component` suffix.

    *Joel Hawksley*

* Fix typo in documentation.

    *Ryo.gift*

* Add inline template example to benchmark script.

    *Andrew Tait*

* Fix benchmark scripts.

    *Andrew Tait*

* Run benchmarks in CI.

    *Joel Hawksley*

## 2.36.0

* Add `slot_type` helper method.

    *Jon Palmer*

* Add test case for rendering a ViewComponent with slots in a controller.

    *Simon Fish*

* Add example ViewComponent to documentation landing page.

    *Joel Hawksley*

* Set maximum line length to 120.

    *Joel Hawksley*

* Setting a collection slot with the plural setter (`component.items(array)` for `renders_many :items`)  returns the array of slots.

    *Jon Palmer*

* Update error messages to be more descriptive and helpful.

    *Joel Hawksley*

* Raise an error if the slot name for renders_many is :contents

    *Simon Fish*

## 2.35.0

* Only load assets for Preview source highlighting if previews are enabled.

    *Joel Hawksley*

* Fix references to moved documentation files.

    *Richard Macklin*

* Ensure consistent indentation with Rubocop.

    *Joel Hawksley*

* Bump `activesupport` upper bound from `< 7.0` to `< 8.0`.

    *Richard Macklin*

* Add ERB Lint for a few basic rules.

    *Joel Hawksley*

* Sort `gemspec` dependencies alphabetically.

    *Joel Hawksley*

* Lock `method_source` at `1.0` to avoid open-ended dependency.

    *Joel Hawksley*

* Require all PRs to include changelog entries.

    *Joel Hawksley*

* Rename test app and move files under /test/sandbox.

    *Matt-Yorkley*

* Make view_component_path config option available on ViewComponent::Base.

    *Matt-Yorkley*

* Add @boardfish to Triage.

    *Joel Hawksley*

* Adds support to change default components path (app/components) with `config.view_component.view_component_path`.

    *lfalcao*

* Rename private instance variables (such as @variant) to reduce potential conflicts with subclasses.

    *Joel Hawksley*

* Add documentation for configuration options.

    *Joel Hawksley*

* Add view helper `preview_source` for rendering a source code preview below previews.
* Add config option `config.view_component.show_previews_source` for enabling the source preview.

    *Johannes Engl*

* Add documentation for compatibility with ActionText.

    *Jared Planter*

## 2.34.0

* Add the ability to enable ActiveSupport notifications (`!render.view_component` event) with `config.view_component.instrumentation_enabled`.

    *Svyatoslav Kryukov*

* Add [Generators](https://viewcomponent.org/guide/generators.html) page to documentation.

    *Hans Lemuet*

* Fix bug where ViewComponents didn't work in ActionMailers.

    *dark-panda*

## 2.33.0

* Add support for `_iteration` parameter when rendering in a collection

    *Will Cosgrove*

* Don't raise an error when rendering empty components.

    *Alex Robbin*

## 2.32.0

* Enable previews by default in test environment.

    *Edouard Piron*

* Fix test helper compatibility with Rails 7.0, TestRequest, and TestSession.

    *Leo Correa*

* Add experimental `_output_postamble` lifecyle method.

    *Joel Hawksley*

* Add compatibility notes on FAQ.

    *Matheus Richard*

* Add Bridgetown on Compatibility documentation.

    *Matheus Richard*

* Are you interested in building the future of ViewComponent? GitHub is looking to hire a Senior Engineer to work on Primer ViewComponents and ViewComponent. Apply here: [US/Canada](https://github.com/careers) / [Europe](https://boards.greenhouse.io/github/jobs/3132294). Feel free to reach out to joelhawksley@github.com with any questions.

    *Joel Hawksley*

## 2.31.2

* Patch XSS vulnerability in `ViewComponent::Translatable` module caused by improperly escaped interpolation arguments.

    *Cameron Dutro*

## 2.31.1

* Fix `DEPRECATION WARNING: before_render_check` when compiling `ViewComponent::Base`

    *Dave Kroondyk*

## 2.31.0

_Note: This release includes an underlying change to Slots that may affect incorrect usage of the API, where Slots were set on a line prefixed by `<%=`. The result of setting a Slot shouldn't be returned. (`<%`)_

* Add `#with_content` to allow setting content without a block.

    *Jordan Raine, Manuel Puyol*

* Add `with_request_url` test helper.

    *Mario Schüttel*

* Improve feature parity with Rails translations
  * Don't create a translation back end if the component has no translation file
  * Mark translation keys ending with `html` as HTML-safe
  * Always convert keys to String
  * Support multiple keys

    *Elia Schito*

* Fix errors on `asset_url` helpers when `asset_host` has no protocol.

    *Elia Schito*

* Prevent slots from overriding the `#content` method when registering a slot with that name.

    *Blake Williams*

* Deprecate `with_slot` in favor of the new [slots API](https://viewcomponent.org/guide/slots.html).

    *Manuel Puyol*

## 2.30.0

* Deprecate `with_content_areas` in favor of [slots](https://viewcomponent.org/guide/slots.html).

    *Joel Hawksley*

## 2.29.0

* Allow Slot lambdas to share data from the parent component and allow chaining on the returned component.

    *Sjors Baltus, Blake Williams*

* Experimental: Add `ViewComponent::Translatable`
  * `t` and `translate` now will look first into the sidecar YAML translations file.
  * `helpers.t` and `I18n.t` still reference the global Rails translation files.
  * `l` and `localize` will still reference the global Rails translation files.

    *Elia Schito*

* Fix rendering output of pass through slots when using HAML.

    *Alex Robbin, Blake Williams*

* Experimental: call `._sidecar_files` to fetch the sidecar files for a given list of extensions, for example passing `["yml", "yaml"]`.

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

* Delay evaluating component `content` in `render?`, preventing the `content` block from being evaluated when `render?` returns false.

    *Blake Williams*

* Don't generate template when using `--inline` flag.

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
  * Slots no longer use the `content` attribute to render content, instead relying on `to_s`. for example `<%= my_slot %>`.
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

* Raise an error if controller or view context is accessed during initialize as they're only available in render.

    *Julian Nadeau*

* Collate test coverage across CI builds, ensuring 100% test coverage.

    *Joel Hawksley*

## 2.18.1

* Fix bug where previews didn't work when monkey patch was disabled.

    *Mixer Gutierrez*

## 2.18.0

* Fix auto loading of previews (changes no longer require a server restart)

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

    *Juan Manuel Ramallo*

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

* Raise an `ArgumentError` with a helpful message when Ruby can't parse a component class.

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

* Fix bug where template couldn't be found if `inherited` was redefined.

    *Joel Hawksley*

## v2.2.0

* Add support for `config.action_view.annotate_template_file_names` (coming in Rails 6.1).

    *Joel Hawksley*

* Remove initializer requirement from the component.

    *Vasiliy Ermolovich*

## v2.1.0

* Support rendering collections (for example, `render(MyComponent.with_collection(@items))`).

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

* ViewComponent generators don't not prompt for content requirement.

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

* Add `#render?` hook to allow components to be no-ops.

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

<!-- vale off -->
* Fix edge case issue with extracting variants from less conventional source_locations.

    *Ryan Workman*
<!-- vale on -->

## v1.6.0

* Avoid dropping elements in the render_inline test helper.

    *@dark-panda*

* Add test for helpers.asset_url.

    *Christopher Coleman*

* Add rudimentary compatibility with better_html.

    *Joel Hawksley*

* Template-less variants fall back to default template.

    *Asger Behncke Jacobsen, Cesario Uy*

* Generated tests use new naming convention.

    *Simon Træls Ravn*

* Eliminate sqlite dependency.

    *Simon Dawson*

* Add support for rendering components via #to_component_class

    *Vinicius Stock*

## v1.5.3

<!-- vale off -->
* Add support for RSpec to generators.

    *Dylan Clark, Ryan Workman*
<!-- vale on -->

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

<!-- vale off -->
* Fix issue with generating component method signatures.

    *Ryan Workman, Dylan Clark*
<!-- vale off -->

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

* Don't raise error when sidecar files that aren't templates exist.

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
