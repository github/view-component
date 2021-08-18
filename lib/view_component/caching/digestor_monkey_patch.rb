# frozen_string_literal: true

module ViewComponent
  module Caching
    module DigestorMonkeyPatch
      def self.prepended(base)
        base.singleton_class.prepend(ClassMethods)
      end

      module ClassMethods
        def tree(name, finder, partial = false, seen = {})
          logical_name = name.gsub(%r|/_|, "/")
          interpolated = name.include?("#")
          component    = name.end_with?("Component")

          if !interpolated && (template = find_template(finder, logical_name, [], partial, component))
            if node = seen[template.identifier] # handle cycles in the tree
              node
            else
              node = seen[template.identifier] = ActionView::Digestor::Node.create(name, logical_name, template, partial)

              deps = ActionView::DependencyTracker.find_dependencies(name, template, finder.view_paths)
              deps.uniq { |n| n.gsub(%r|/_|, "/") }.each do |dep_file|
                # The `partial` argument needs to be forced to `false` if passing a component's
                # template files to #tree, but `true` if we're handling a rails template.
                node.children << tree(dep_file, finder, !component, seen)
              end
              node
            end
          else
            unless interpolated # Dynamic template partial names can never be tracked
              logger.error "  Couldn't find template for digesting: #{name}"
            end

            seen[name] ||= ActionView::Digestor::Missing.new(name, logical_name, nil)
          end
        end

        private

        def find_template(finder, name, prefixes, partial, component)
          if component
            finder = component_finder
            partial = false
            name = name.underscore
          end

          finder.disable_cache do
            finder.find_all(name, prefixes, partial, []).first
          end
        end

        def component_finder
          @component_finder ||= ActionView::LookupContext.new(
            ActionView::PathSet.new([Rails.root.join(ViewComponent::Base.view_component_path)]),
            formats: [:rb]
          )
        end
      end
    end
  end
end
