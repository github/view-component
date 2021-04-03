# frozen_string_literal: true

require "active_support/concern"

require "view_component/slot"

module ViewComponent
  module Slotable
    extend ActiveSupport::Concern

    included do
      # Hash of registered Slots
      class_attribute :slots
      self.slots = {}
    end

    class_methods do
      # support initializing slots as:
      #
      # with_slot(
      #   :header,
      #   collection: true|false,
      #   class_name: "Header" # class name string, used to instantiate Slot
      # )
      def with_slot(*slot_names, collection: false, class_name: nil)
        slot_names.each do |slot_name|
          # Ensure slot_name is not already declared
          if self.slots.key?(slot_name)
            raise ArgumentError.new("#{slot_name} slot declared multiple times")
          end

          # Ensure slot name is not :content
          if slot_name == :content
            raise ArgumentError.new ":content is a reserved slot name. Please use another name, such as ':body'"
          end

          # Set the name of the method used to access the Slot(s)
          accessor_name =
            if collection
              # If Slot is a collection, set the accessor
              # name to the pluralized form of the slot name
              # For example: :tab => :tabs
              ActiveSupport::Inflector.pluralize(slot_name)
            else
              slot_name
            end

          instance_variable_name = "@#{accessor_name}"

          # If the slot is a collection, define an accesor that defaults to an empty array
          if collection
            class_eval <<-RUBY, __FILE__, __LINE__ + 1
              def #{accessor_name}
                content unless content_evaluated? # ensure content is loaded so slots will be defined
                #{instance_variable_name} ||= []
              end
            RUBY
          else
            class_eval <<-RUBY, __FILE__, __LINE__ + 1
              def #{accessor_name}
                content unless content_evaluated? # ensure content is loaded so slots will be defined
                #{instance_variable_name} if defined?(#{instance_variable_name})
              end
            RUBY
          end

          # Default class_name to ViewComponent::Slot
          class_name = "ViewComponent::Slot" unless class_name.present?

          # Register the slot on the component
          self.slots[slot_name] = {
            class_name: class_name,
            instance_variable_name: instance_variable_name,
            collection: collection
          }
        end
      end

      def inherited(child)
        # Clone slot configuration into child class
        # see #test_slots_pollution
        child.slots = self.slots.clone

        super
      end
    end

    # Build a Slot instance on a component,
    # exposing it for use inside the
    # component template.
    #
    # slot: Name of Slot, in symbol form
    # **args: Arguments to be passed to Slot initializer
    #
    # For example:
    # <%= render(SlotsComponent.new) do |component| %>
    #   <% component.slot(:footer, class_names: "footer-class") do %>
    #     <p>This is my footer!</p>
    #   <% end %>
    # <% end %>
    #
    def slot(slot_name, **args, &block)
      # Raise ArgumentError if `slot` does not exist
      unless slots.keys.include?(slot_name)
        raise ArgumentError.new "Unknown slot '#{slot_name}' - expected one of '#{slots.keys}'"
      end

      slot = slots[slot_name]

      # The class name of the Slot, such as Header
      slot_class = self.class.const_get(slot[:class_name])

      unless slot_class <= ViewComponent::Slot
        raise ArgumentError.new "#{slot[:class_name]} must inherit from ViewComponent::Slot"
      end

      # Instantiate Slot class, accommodating Slots that don't accept arguments
      slot_instance = args.present? ? slot_class.new(**args) : slot_class.new

      # Capture block and assign to slot_instance#content
      slot_instance.content = view_context.capture(&block).to_s.strip.html_safe if block_given?

      if slot[:collection]
        # Initialize instance variable as an empty array
        # if slot is a collection and has yet to be initialized
        unless instance_variable_defined?(slot[:instance_variable_name])
          instance_variable_set(slot[:instance_variable_name], [])
        end

        # Append Slot instance to collection accessor Array
        instance_variable_get(slot[:instance_variable_name]) << slot_instance
      else
         # Assign the Slot instance to the slot accessor
        instance_variable_set(slot[:instance_variable_name], slot_instance)
      end

      # Return nil, as this method should not output anything to the view itself.
      nil
    end
  end
end
