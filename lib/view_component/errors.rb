module ViewComponent
  class BaseError < StandardError
    def initialize
      super(self.class::MESSAGE)
    end
  end

  class DuplicateSlotContentError < StandardError
    MESSAGE =
      "It looks like a block was provided after calling `with_content` on COMPONENT, " \
      "which means that ViewComponent doesn't know which content to use.\n\n" \
      "To fix this issue, use either `with_content` or a block."

    def initialize(klass_name)
      super(MESSAGE.gsub("COMPONENT", klass_name.to_s))
    end
  end

  class TemplateError < StandardError
    def initialize(errors, templates = nil)
      message = errors.join("\n")

      super(message)
    end
  end

  class MultipleInlineTemplatesError < BaseError
    MESSAGE = "Inline templates can only be defined once per-component."
  end

  class MissingPreviewTemplateError < StandardError
    MESSAGE =
      "A preview template for example EXAMPLE doesn't exist.\n\n" \
      "To fix this issue, create a template for the example."

    def initialize(example)
      super(MESSAGE.gsub("EXAMPLE", example))
    end
  end

  class MissingTemplateError < StandardError
    MESSAGE =
      "No templates for COMPONENT match the request DETAIL.\n\n" \
      "To fix this issue, provide a suitable template."

    def initialize(component, request_detail)
      detail = {
        locale: request_detail.locale,
        formats: request_detail.formats,
        variants: request_detail.variants,
        handlers: request_detail.handlers
      }
      super(MESSAGE.gsub("COMPONENT", component).gsub("DETAIL", detail.inspect))
    end
  end

  class DuplicateContentError < StandardError
    MESSAGE =
      "It looks like a block was provided after calling `with_content` on COMPONENT, " \
      "which means that ViewComponent doesn't know which content to use.\n\n" \
      "To fix this issue, use either `with_content` or a block."

    def initialize(klass_name)
      super(MESSAGE.gsub("COMPONENT", klass_name.to_s))
    end
  end

  class EmptyOrInvalidInitializerError < StandardError
    MESSAGE =
      "The COMPONENT initializer is empty or invalid. " \
      "It must accept the parameter `PARAMETER` to render it as a collection.\n\n" \
      "To fix this issue, update the initializer to accept `PARAMETER`.\n\n" \
      "See [the collections docs](https://viewcomponent.org/guide/collections.html) for more information on rendering collections."

    def initialize(klass_name, parameter)
      super(MESSAGE.gsub("COMPONENT", klass_name.to_s).gsub("PARAMETER", parameter.to_s))
    end
  end

  class MissingCollectionArgumentError < StandardError
    MESSAGE =
      "The initializer for COMPONENT doesn't accept the parameter `PARAMETER`, " \
      "which is required to render it as a collection.\n\n" \
      "To fix this issue, update the initializer to accept `PARAMETER`.\n\n" \
      "See [the collections docs](https://viewcomponent.org/guide/collections.html) for more information on rendering collections."

    def initialize(klass_name, parameter)
      super(MESSAGE.gsub("COMPONENT", klass_name.to_s).gsub("PARAMETER", parameter.to_s))
    end
  end

  class ReservedParameterError < StandardError
    MESSAGE =
      "COMPONENT initializer can't accept the parameter `PARAMETER`, as it will override a " \
      "public ViewComponent method. To fix this issue, rename the parameter."

    def initialize(klass_name, parameter)
      super(MESSAGE.gsub("COMPONENT", klass_name.to_s).gsub("PARAMETER", parameter.to_s))
    end
  end

  class InvalidCollectionArgumentError < BaseError
    MESSAGE =
      "The value of the first argument passed to `with_collection` isn't a valid collection. " \
      "Make sure it responds to `to_ary`."
  end

  class ContentSlotNameError < StandardError
    MESSAGE =
      "COMPONENT declares a slot named content, which is a reserved word in ViewComponent.\n\n" \
      "Content passed to a ViewComponent as a block is captured and assigned to the `content` accessor without having to create an explicit slot.\n\n" \
      "To fix this issue, either use the `content` accessor directly or choose a different slot name."

    def initialize(klass_name)
      super(MESSAGE.gsub("COMPONENT", klass_name.to_s))
    end
  end

  class InvalidSlotDefinitionError < BaseError
    MESSAGE =
      "Invalid slot definition. Please pass a class, " \
      "string, or callable (that is proc, lambda, etc)"
  end

  class InvalidSlotNameError < StandardError
  end

  class SlotPredicateNameError < InvalidSlotNameError
    MESSAGE =
      "COMPONENT declares a slot named SLOT_NAME, which ends with a question mark.\n\n" \
      "This isn't allowed because the ViewComponent framework already provides predicate " \
      "methods ending in `?`.\n\n" \
      "To fix this issue, choose a different name."

    def initialize(klass_name, slot_name)
      super(MESSAGE.gsub("COMPONENT", klass_name.to_s).gsub("SLOT_NAME", slot_name.to_s))
    end
  end

  class RedefinedSlotError < StandardError
    MESSAGE =
      "COMPONENT declares the SLOT_NAME slot multiple times.\n\n" \
      "To fix this issue, choose a different slot name."

    def initialize(klass_name, slot_name)
      super(MESSAGE.gsub("COMPONENT", klass_name.to_s).gsub("SLOT_NAME", slot_name.to_s))
    end
  end

  class ReservedSingularSlotNameError < InvalidSlotNameError
    MESSAGE =
      "COMPONENT declares a slot named SLOT_NAME, which is a reserved word in the ViewComponent framework.\n\n" \
      "To fix this issue, choose a different name."

    def initialize(klass_name, slot_name)
      super(MESSAGE.gsub("COMPONENT", klass_name.to_s).gsub("SLOT_NAME", slot_name.to_s))
    end
  end

  class ReservedPluralSlotNameError < InvalidSlotNameError
    MESSAGE =
      "COMPONENT declares a slot named SLOT_NAME, which is a reserved word in the ViewComponent framework.\n\n" \
      "To fix this issue, choose a different name."

    def initialize(klass_name, slot_name)
      super(MESSAGE.gsub("COMPONENT", klass_name.to_s).gsub("SLOT_NAME", slot_name.to_s))
    end
  end

  class UncountableSlotNameError < InvalidSlotNameError
    MESSAGE =
      "COMPONENT declares a slot named SLOT_NAME, which is an uncountable word\n\n" \
      "To fix this issue, choose a different name."

    def initialize(klass_name, slot_name)
      super(MESSAGE.gsub("COMPONENT", klass_name.to_s).gsub("SLOT_NAME", slot_name.to_s))
    end
  end

  class ContentAlreadySetForPolymorphicSlotError < StandardError
    MESSAGE = "Content for slot SLOT_NAME has already been provided."

    def initialize(slot_name)
      super(MESSAGE.gsub("SLOT_NAME", slot_name.to_s))
    end
  end

  class NilWithContentError < BaseError
    MESSAGE =
      "No content provided to `#with_content` for #{self}.\n\n" \
      "To fix this issue, pass a value."
  end

  class TranslateCalledBeforeRenderError < BaseError
    MESSAGE =
      "`#translate` can't be used during initialization as it depends " \
      "on the view context that only exists once a ViewComponent is passed to " \
      "the Rails render pipeline.\n\n" \
      "It's sometimes possible to fix this issue by moving code dependent on " \
      "`#translate` to a [`#before_render` method](https://viewcomponent.org/api.html#before_render--void)."
  end

  class HelpersCalledBeforeRenderError < BaseError
    MESSAGE =
      "`#helpers` can't be used during initialization as it depends " \
      "on the view context that only exists once a ViewComponent is passed to " \
      "the Rails render pipeline.\n\n" \
      "It's sometimes possible to fix this issue by moving code dependent on " \
      "`#helpers` to a [`#before_render` method](https://viewcomponent.org/api.html#before_render--void)."
  end

  class ControllerCalledBeforeRenderError < BaseError
    MESSAGE =
      "`#controller` can't be used during initialization, as it depends " \
      "on the view context that only exists once a ViewComponent is passed to " \
      "the Rails render pipeline.\n\n" \
      "It's sometimes possible to fix this issue by moving code dependent on " \
      "`#controller` to a [`#before_render` method](https://viewcomponent.org/api.html#before_render--void)."
  end

  # :nocov:
  class NoMatchingTemplatesForPreviewError < StandardError
    MESSAGE = "Found 0 matches for templates for TEMPLATE_IDENTIFIER."

    def initialize(template_identifier)
      super(MESSAGE.gsub("TEMPLATE_IDENTIFIER", template_identifier))
    end
  end

  class MultipleMatchingTemplatesForPreviewError < StandardError
    MESSAGE = "Found multiple templates for TEMPLATE_IDENTIFIER."

    def initialize(template_identifier)
      super(MESSAGE.gsub("TEMPLATE_IDENTIFIER", template_identifier))
    end
  end
  # :nocov:

  class SystemTestControllerOnlyAllowedInTestError < BaseError
    MESSAGE = "ViewComponent SystemTest controller must only be called in a test environment for security reasons."
  end

  class SystemTestControllerNefariousPathError < BaseError
    MESSAGE = "ViewComponent SystemTest controller attempted to load a file outside of the expected directory."
  end

  class AlreadyDefinedPolymorphicSlotSetterError < StandardError
    MESSAGE =
      "A method called 'SETTER_METHOD_NAME' already exists and would be overwritten by the 'SETTER_NAME' polymorphic " \
      "slot setter.\n\nPlease choose a different setter name."

    def initialize(setter_method_name, setter_name)
      super(MESSAGE.gsub("SETTER_METHOD_NAME", setter_method_name.to_s).gsub("SETTER_NAME", setter_name.to_s))
    end
  end
end
