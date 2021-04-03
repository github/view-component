# frozen_string_literal: true

Dummy::Application.routes.draw do
  root to: "integration_examples#index"
  get :content_areas, to: "integration_examples#content_areas"
  get :slots, to: "integration_examples#slots"
  get :empty_slot, to: "integration_examples#empty_slot"
  get :partial, to: "integration_examples#partial"
  get :content, to: "integration_examples#content"
  get :variants, to: "integration_examples#variants"
  get :products, to: "integration_examples#products"
  get :inline_products, to: "integration_examples#inline_products"
  get :cached, to: "integration_examples#cached"
  get :render_check, to: "integration_examples#render_check"
  get :controller_inline, to: "integration_examples#controller_inline"
  get :controller_inline_baseline, to: "integration_examples#controller_inline_baseline"
  get :controller_to_string, to: "integration_examples#controller_to_string"
  get :render_component, to: "integration_examples#render_component"
  get :controller_inline_render_component, to: "integration_examples#controller_inline_render_component"
  get :controller_to_string_render_component, to: "integration_examples#controller_to_string_render_component"
end
