# frozen_string_literal: true

class CustomTestControllerController < ActionController::Base
  helper_method :foo

  private

  def foo
    "foo"
  end
end
