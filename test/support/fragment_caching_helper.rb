# frozen_string_literal: true

require "view_component/caching/digestor_monkey_patch"
require "view_component/caching/erb_tracker"
require "view_component/caching/component_tracker"

module FragmentCachingHelper
  def set_tracker(extension, tracker)
    ActionView::DependencyTracker.remove_tracker ActionView::Template.handler_for_extension(extension)
    ActionView::DependencyTracker.register_tracker extension, tracker if tracker
  end

  def find_template(name, finder)
    finder.find_all(name, [], false, []).first
  end

  def template_finder
    ActionView::LookupContext.new(
      ActionView::PathSet.new([Rails.root.join("app/views")]),
      formats: [:html]
    )
  end

  def component_finder
    ActionView::LookupContext.new(
      ActionView::PathSet.new([Rails.root.join("app/components")]),
      formats: [:rb]
    )
  end

  def digest(name, template, finder)
    ActionView::Digestor.digest(
      name: name, format: template.format, finder: finder
    )
  end

  def clear_digest_cache!(finder)
    finder.digest_cache.clear
  end

  def fragment_caching_setup
    # Apply monkey patch to ActionView::Digestor
    ActionView::Digestor.prepend ViewComponent::Caching::DigestorMonkeyPatch

    Mime::Type.register "text/ruby", :rb
    set_tracker :erb, ViewComponent::Caching::ERBTracker
    set_tracker :rb, ViewComponent::Caching::ComponentTracker
  end

  def fragment_caching_teardown
    # Reset ActionView::Digestor to it's pre-patched state
    ActionView.send :remove_const, :Digestor
    load "action_view/digestor.rb"

    Mime::Type.unregister :rb
    set_tracker :erb, ActionView::DependencyTracker::ERBTracker
    set_tracker :rb, nil
  end
end
