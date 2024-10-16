class RequestParamComponent < ViewComponent::Base
  def initialize(request:)
    @request = request
  end

  def call
    request
  end
end