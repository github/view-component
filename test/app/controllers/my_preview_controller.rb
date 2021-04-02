# frozen_string_literal: true

class MyPreviewController < ViewComponentsController
  def index
    render plain: "Custom controller"
  end
end
