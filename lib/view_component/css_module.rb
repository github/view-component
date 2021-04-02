# frozen_string_literal: true

require "sass"

module ViewComponent
  class CSSModule < Sass::Tree::Visitors::Base
    def initialize(module_name, raw_css)
      @module_name, @mappings = module_name, {}

      @css_root = Sass::SCSS::CssParser.new(raw_css, "(CSSModules)", 1).parse

      @module_hash = compute_hash
    end

    # Given a `module_name` and `raw_css`, rewrite `raw_css`
    # apply opaque transformations to `raw_css` so that
    # selectors can only be accessed programatically,
    # not by class name literals.
    def self.rewrite(*args)
      new(*args).rewrite
    end

    def rewrite
      Sass::Tree::Visitors::SetOptions.visit(@css_root, {})

      css = @css_root.render

      binding.irb if css.include?("flex")

      {
        mappings: mappings,
        css: @css_root.render
      }
    end

    private

    # Generate a short, random-ish token to prevent CSS selector collisions.
    def compute_hash
      Digest::MD5.hexdigest(@module_name).first(5)
    end

    def visit_rule(node)
      node.parsed_rules = rebuild_parsed_rules(node.parsed_rules)
    end

    def mappings
      visit(@css_root)

      @mappings
    end

    def rebuild_parsed_rules(parsed_rules)
      new_members = parsed_rules.members.map do |member_seq|
        deeply_transform(member_seq)
      end
      Sass::Selector::CommaSequence.new(new_members)
    end

    # Combine `module_name` and `selector`, but don't prepend a `.` or `#`
    # because this value will be inserted into the HTML page as `class=` or `id=`
    # @param module_name [String] A CSS module name
    # @param selector [String] A would-be DOM selector (without the leading `.` or `#`)
    # @return [String] An opaque selector for this module-selector pair
    def modulize_selector(selector)
      after = "#{@module_name}_#{@module_hash}_#{selector}"

      @mappings[selector] = after

      after
    end

    # We know this is a modulized rule
    # now we should transform its ID and classes to modulized
    def deeply_transform(seq)
      case seq
      when Sass::Selector::AbstractSequence
        new_members = seq.members.map { |m| deeply_transform(m) }
        new_members.compact! # maybe a module selector returned nil
        clone_sequence(seq, new_members)
      when Sass::Selector::Id, Sass::Selector::Class
        # Sass 3.2 has an array here, Sass 3.4 has a string:
        selector_name = seq.name.is_a?(Array) ? seq.name.first : seq.name
        modulized_name = modulize_selector(selector_name)
        seq.class.new(modulized_name)
      when Sass::Selector::Pseudo
        if seq.to_s =~ /:module/
          nil
        else
          seq
        end
      else
        seq
      end
    end

    # Make a new kind of `seq`, containing `new_members`
    def clone_sequence(seq, new_members)
      case seq
      when Sass::Selector::Sequence
        seq.class.new(new_members)
      when Sass::Selector::SimpleSequence
        seq.class.new(new_members, seq.subject?)
      end
    end
  end
end
