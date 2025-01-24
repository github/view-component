# frozen_string_literal: true

class IntegrationExamplesController < ActionController::Base
  layout false

  def variants
    request.variant = params[:variant].to_sym if params[:variant]
  end

  def controller_inline
    render(ControllerInlineComponent.new(message: "bar"))
  end

  def controller_inline_with_block
    render(ControllerInlineWithBlockComponent.new(message: "bar").tap do |c|
      c.with_slot(name: "baz")
      c.with_content("bam")
    end)
  end

  def controller_inline_baseline
    render("integration_examples/_controller_inline", locals: {message: "bar"})
  end

  def controller_to_string
    render_to_string("integration_examples/_controller_inline", locals: {message: "bar"})

    render(plain: render_to_string(ControllerInlineComponent.new(message: "bar")))
  end

  def helpers_proxy_component
    render(plain: render_to_string(HelpersProxyComponent.new))
  end

  def products
    @products = [Product.new(name: "Radio clock"), Product.new(name: "Mints")]
  end

  def inline_products
    products = [Product.new(name: "Radio clock"), Product.new(name: "Mints")]

    render(ProductComponent.with_collection(products, notice: "Today only"))
  end

  def inherited_sidecar
    render(InheritedSidecarComponent.new)
  end

  def inherited_from_uncompilable_component
    render(InheritedFromUncompilableComponent.new)
  end

  def unsafe_component
    render(UnsafeComponent.new)
  end

  def unsafe_preamble_component
    render(UnsafePreambleComponent.new)
  end

  def unsafe_postamble_component
    render(UnsafePostambleComponent.new)
  end

  def multiple_formats_component
    render(MultipleFormatsComponent.new)
  end

  def turbo_stream
    respond_to { |format| format.turbo_stream { render TurboStreamComponent.new } }
  end
end
