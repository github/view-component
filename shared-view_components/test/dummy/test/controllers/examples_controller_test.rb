require_relative "../../../test_helper"

class ExamplesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get examples_index_url
    assert_response :success
  end
end
