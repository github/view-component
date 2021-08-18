# frozen_string_literal: true

module ViewComponent
  module Caching
    class ERBTracker < ActionView::DependencyTracker::ERBTracker
      # Matches a view component class eg:
      # CommentComponent.new("example")           => "CommentComponent"
      # Topic::Component.with_collection(@topics) => "Topic::Component"
      COMPONENT = /
        (?<component>[A-Z][A-Za-z:]*Component)  # a class name captured as COMPONENT
        \.                                      # followed by .
      /x

      # Include component matches when parsing render calls
      RENDER_ARGUMENTS = /\A
        (?:\s*\(?\s*)                                          # optional opening paren surrounded by spaces
        (?:.*?#{PARTIAL_HASH_KEY}|#{LAYOUT_HASH_KEY})?         # optional hash, up to the partial or layout key declaration
        (?:#{COMPONENT}|#{STRING}|#{VARIABLE_OR_METHOD_CHAIN}) # finally, the dependency name of interest
      /xm

      private

      def render_dependencies
        render_dependencies = []
        render_calls = source.split(/\brender\b/).drop(1)

        render_calls.each do |arguments|
          add_dependencies(render_dependencies, arguments, self.class::LAYOUT_DEPENDENCY)
          add_dependencies(render_dependencies, arguments, self.class::RENDER_ARGUMENTS)
        end

        render_dependencies.uniq
      end

      def add_dependencies(render_dependencies, arguments, pattern)
        arguments.scan(pattern) do
          match = Regexp.last_match.named_captures
          add_component_dependency(render_dependencies, match["component"])
          add_dynamic_dependency(render_dependencies, match["dynamic"])
          add_static_dependency(render_dependencies, match["static"], match["quote"])
        end
      end

      def add_component_dependency(dependencies, dependency)
        dependencies << dependency if dependency
      end

      def add_static_dependency(dependencies, dependency, quote_type)
        if quote_type == '"'
          # Ignore if there is interpolation
          return if dependency.include?('#{')
        end

        if dependency
          if dependency.include?("/")
            dependencies << dependency
          else
            dependencies << "#{directory}/#{dependency}"
          end
        end
      end
    end
  end
end
