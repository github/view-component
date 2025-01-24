# frozen_string_literal: true

require "active_support/concern"
require "active_support/inflector/inflections"
require "view_component/slot"

module ViewComponent
  module Slotable
    extend ActiveSupport::Concern

    RESERVED_NAMES = {
      singular: %i[content render].freeze,
      plural: %i[contents renders].freeze
    }.freeze

    # Setup component slot state
    included do
      # Hash of registered Slots
      class_attribute :registered_slots
      self.registered_slots = {}
    end

    class_methods do
      ##
      # Registers a sub-component
      #
      # = Example
      #
      #   renders_one :header -> (classes:) do
      #     HeaderComponent.new(classes: classes)
      #   end
      #
      #   # OR
      #
      #   renders_one :header, HeaderComponent
      #
      #   where `HeaderComponent` is defined as:
      #
      #   class HeaderComponent < ViewComponent::Base
      #     def initialize(classes:)
      #       @classes = classes
      #     end
      #   end
      #
      #   and has the following template:
      #
      #   <header class="<%= @classes %>">
      #     <%= content %>
      #   </header>
      #
      # = Rendering sub-component content
      #
      # The component's sidecar template can access the sub-component by calling a
      # helper method with the same name as the sub-component.
      #
      #   <h1>
      #     <%= header do %>
      #       My header title
      #     <% end %>
      #   </h1>
      #
      # = Setting sub-component content
      #
      # Consumers of the component can render a sub-component by calling a
      # helper method with the same name as the slot prefixed with `with_`.
      #
      #   <%= render_inline(MyComponent.new) do |component| %>
      #     <% component.with_header(classes: "Foo") do %>
      #       <p>Bar</p>
      #     <% end %>
      #   <% end %>
      #
      # Additionally, content can be set by calling `with_SLOT_NAME_content`
      # on the component instance.
      #
      #   <%= render_inline(MyComponent.new.with_header_content("Foo")) %>
      def renders_one(slot_name, callable = nil)
        validate_singular_slot_name(slot_name)

        if callable.is_a?(Hash) && callable.key?(:types)
          register_polymorphic_slot(slot_name, callable[:types], collection: false)
        else
          validate_plural_slot_name(ActiveSupport::Inflector.pluralize(slot_name).to_sym)

          setter_method_name = :"with_#{slot_name}"

          define_method setter_method_name do |*args, &block|
            set_slot(slot_name, nil, *args, &block)
          end
          ruby2_keywords(setter_method_name) if respond_to?(:ruby2_keywords, true)

          self::GeneratedSlotMethods.define_method slot_name do
            get_slot(slot_name)
          end

          self::GeneratedSlotMethods.define_method :"#{slot_name}?" do
            get_slot(slot_name).present?
          end

          define_method :"with_#{slot_name}_content" do |content|
            send(setter_method_name) { content.to_s }

            self
          end

          register_slot(slot_name, collection: false, callable: callable)
        end
      end

      ##
      # Registers a collection sub-component
      #
      # = Example
      #
      #   renders_many :items, -> (name:) { ItemComponent.new(name: name }
      #
      #   # OR
      #
      #   renders_many :items, ItemComponent
      #
      # = Rendering sub-components
      #
      # The component's sidecar template can access the slot by calling a
      # helper method with the same name as the slot.
      #
      #   <h1>
      #     <% items.each do |item| %>
      #       <%= item %>
      #     <% end %>
      #   </h1>
      #
      # = Setting sub-component content
      #
      # Consumers of the component can set the content of a slot by calling a
      # helper method with the same name as the slot prefixed with `with_`. The
      # method can be called multiple times to append to the slot.
      #
      #   <%= render_inline(MyComponent.new) do |component| %>
      #     <% component.with_item(name: "Foo") do %>
      #       <p>One</p>
      #     <% end %>
      #
      #     <% component.with_item(name: "Bar") do %>
      #       <p>two</p>
      #     <% end %>
      #   <% end %>
      def renders_many(slot_name, callable = nil)
        validate_plural_slot_name(slot_name)

        if callable.is_a?(Hash) && callable.key?(:types)
          register_polymorphic_slot(slot_name, callable[:types], collection: true)
        else
          singular_name = ActiveSupport::Inflector.singularize(slot_name)
          validate_singular_slot_name(ActiveSupport::Inflector.singularize(slot_name).to_sym)

          setter_method_name = :"with_#{singular_name}"

          define_method setter_method_name do |*args, &block|
            set_slot(slot_name, nil, *args, &block)
          end
          ruby2_keywords(setter_method_name) if respond_to?(:ruby2_keywords, true)

          define_method :"with_#{singular_name}_content" do |content|
            send(setter_method_name) { content.to_s }

            self
          end

          define_method :"with_#{slot_name}" do |collection_args = nil, &block|
            collection_args.map do |args|
              if args.respond_to?(:to_hash)
                set_slot(slot_name, nil, **args, &block)
              else
                set_slot(slot_name, nil, *args, &block)
              end
            end
          end

          self::GeneratedSlotMethods.define_method slot_name do
            get_slot(slot_name)
          end

          self::GeneratedSlotMethods.define_method :"#{slot_name}?" do
            get_slot(slot_name).present?
          end

          register_slot(slot_name, collection: true, callable: callable)
        end
      end

      def slot_type(slot_name)
        registered_slot = registered_slots[slot_name]
        if registered_slot
          registered_slot[:collection] ? :collection : :single
        else
          plural_slot_name = ActiveSupport::Inflector.pluralize(slot_name).to_sym
          plural_registered_slot = registered_slots[plural_slot_name]
          plural_registered_slot&.fetch(:collection) ? :collection_item : nil
        end
      end

      def inherited(child)
        # Clone slot configuration into child class
        # see #test_slots_pollution
        child.registered_slots = registered_slots.clone

        # Add a module for slot methods, allowing them to be overriden by the component class
        # see #test_slot_name_can_be_overriden
        unless child.const_defined?(:GeneratedSlotMethods, false)
          generated_slot_methods = Module.new
          child.const_set(:GeneratedSlotMethods, generated_slot_methods)
          child.include generated_slot_methods
        end

        super
      end

      def register_polymorphic_slot(slot_name, types, collection:)
        self::GeneratedSlotMethods.define_method(slot_name) do
          get_slot(slot_name)
        end

        self::GeneratedSlotMethods.define_method(:"#{slot_name}?") do
          get_slot(slot_name).present?
        end

        renderable_hash = types.each_with_object({}) do |(poly_type, poly_attributes_or_callable), memo|
          if poly_attributes_or_callable.is_a?(Hash)
            poly_callable = poly_attributes_or_callable[:renders]
            poly_slot_name = poly_attributes_or_callable[:as]
          else
            poly_callable = poly_attributes_or_callable
            poly_slot_name = nil
          end

          poly_slot_name ||=
            if collection
              "#{ActiveSupport::Inflector.singularize(slot_name)}_#{poly_type}"
            else
              "#{slot_name}_#{poly_type}"
            end

          memo[poly_type] = define_slot(
            poly_slot_name, collection: collection, callable: poly_callable
          )

          setter_method_name = :"with_#{poly_slot_name}"

          if instance_methods.include?(setter_method_name)
            raise AlreadyDefinedPolymorphicSlotSetterError.new(setter_method_name, poly_slot_name)
          end

          define_method(setter_method_name) do |*args, &block|
            set_polymorphic_slot(slot_name, poly_type, *args, &block)
          end
          ruby2_keywords(setter_method_name) if respond_to?(:ruby2_keywords, true)

          define_method :"with_#{poly_slot_name}_content" do |content|
            send(setter_method_name) { content.to_s }

            self
          end
        end

        registered_slots[slot_name] = {
          collection: collection,
          renderable_hash: renderable_hash
        }
      end

      # Called by the compiler, as instance methods are not defined when slots are first registered
      def register_default_slots
        registered_slots.each do |slot_name, config|
          config[:default_method] = instance_methods.find { |method_name| method_name == :"default_#{slot_name}" }

          registered_slots[slot_name] = config
        end
      end

      private

      def register_slot(slot_name, **kwargs)
        registered_slots[slot_name] = define_slot(slot_name, **kwargs)
      end

      def define_slot(slot_name, collection:, callable:)
        slot = {collection: collection}
        return slot unless callable

        # If callable responds to `render_in`, we set it on the slot as a renderable
        if callable.respond_to?(:method_defined?) && callable.method_defined?(:render_in)
          slot[:renderable] = callable
        elsif callable.is_a?(String)
          # If callable is a string, we assume it's referencing an internal class
          slot[:renderable_class_name] = callable
        elsif callable.respond_to?(:call)
          # If slot doesn't respond to `render_in`, we assume it's a proc,
          # define a method, and save a reference to it to call when setting
          method_name = :"_call_#{slot_name}"
          define_method method_name, &callable
          slot[:renderable_function] = instance_method(method_name)
        else
          raise(InvalidSlotDefinitionError)
        end

        slot
      end

      def validate_plural_slot_name(slot_name)
        if slot_name.to_sym == :contents && !__vc_content_is_a_slot?
          if RESERVED_NAMES[:plural].include?(slot_name.to_sym)
            raise ReservedPluralSlotNameError.new(name, slot_name)
          end
        end

        raise_if_slot_name_uncountable(slot_name)
        raise_if_slot_conflicts_with_call(slot_name)
        raise_if_slot_ends_with_question_mark(slot_name)
        raise_if_slot_registered(slot_name)
      end

      def validate_singular_slot_name(slot_name)
        if slot_name.to_sym == :content && !__vc_content_is_a_slot?
          raise ContentSlotNameError.new(name)
        elsif !__vc_content_is_a_slot?
          if RESERVED_NAMES[:singular].include?(slot_name.to_sym)
            raise ReservedSingularSlotNameError.new(name, slot_name)
          end
        end

        raise_if_slot_conflicts_with_call(slot_name)
        raise_if_slot_ends_with_question_mark(slot_name)
        raise_if_slot_registered(slot_name)
      end

      def raise_if_slot_registered(slot_name)
        if registered_slots.key?(slot_name)
          # TODO remove? This breaks overriding slots when slots are inherited
          raise RedefinedSlotError.new(name, slot_name)
        end
      end

      def raise_if_slot_ends_with_question_mark(slot_name)
        raise SlotPredicateNameError.new(name, slot_name) if slot_name.to_s.end_with?("?")
      end

      def raise_if_slot_conflicts_with_call(slot_name)
        if slot_name.start_with?("call_")
          raise InvalidSlotNameError, "Slot cannot start with 'call_'. Please rename #{slot_name}"
        end
      end

      def raise_if_slot_name_uncountable(slot_name)
        slot_name = slot_name.to_s
        if slot_name.pluralize == slot_name.singularize
          raise UncountableSlotNameError.new(name, slot_name)
        end
      end
    end

    def get_slot(slot_name)
      content unless content_evaluated? # ensure content is loaded so slots will be defined

      slot = self.class.registered_slots[slot_name]
      @__vc_set_slots ||= {}

      if @__vc_set_slots[slot_name]
        return @__vc_set_slots[slot_name]
      end

      if slot[:collection]
        []
      end
    end

    def set_slot(slot_name, slot_definition = nil, *args, &block)
      slot_definition ||= self.class.registered_slots[slot_name]
      slot = Slot.new(self)

      # Passing the block to the sub-component wrapper like this has two
      # benefits:
      #
      # 1. If this is a `content_area` style sub-component, we will render the
      # block via the `slot`
      #
      # 2. Since we have to pass block content to components when calling
      # `render`, evaluating the block here would require us to call
      # `view_context.capture` twice, which is slower
      slot.__vc_content_block = block if block

      # If class
      if slot_definition[:renderable]
        slot.__vc_component_instance = slot_definition[:renderable].new(*args)
      # If class name as a string
      elsif slot_definition[:renderable_class_name]
        slot.__vc_component_instance =
          self.class.const_get(slot_definition[:renderable_class_name]).new(*args)
      # If passed a lambda
      elsif slot_definition[:renderable_function]
        # Use `bind(self)` to ensure lambda is executed in the context of the
        # current component. This is necessary to allow the lambda to access helper
        # methods like `content_tag` as well as parent component state.
        renderable_function = slot_definition[:renderable_function].bind(self)
        renderable_value =
          if block
            renderable_function.call(*args) do |*rargs|
              view_context.capture(*rargs, &block)
            end
          else
            renderable_function.call(*args)
          end

        # Function calls can return components, so if it's a component handle it specially
        if renderable_value.respond_to?(:render_in)
          slot.__vc_component_instance = renderable_value
        else
          slot.__vc_content = renderable_value
        end
      end

      @__vc_set_slots ||= {}

      if slot_definition[:collection]
        @__vc_set_slots[slot_name] ||= []
        @__vc_set_slots[slot_name].push(slot)
      else
        @__vc_set_slots[slot_name] = slot
      end

      slot
    end
    ruby2_keywords(:set_slot) if respond_to?(:ruby2_keywords, true)

    def set_polymorphic_slot(slot_name, poly_type = nil, *args, &block)
      slot_definition = self.class.registered_slots[slot_name]

      if !slot_definition[:collection] && (defined?(@__vc_set_slots) && @__vc_set_slots[slot_name])
        raise ContentAlreadySetForPolymorphicSlotError.new(slot_name)
      end

      poly_def = slot_definition[:renderable_hash][poly_type]

      set_slot(slot_name, poly_def, *args, &block)
    end
    ruby2_keywords(:set_polymorphic_slot) if respond_to?(:ruby2_keywords, true)
  end
end
