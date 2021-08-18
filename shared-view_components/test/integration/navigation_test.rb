require "test_helper"

class NavigationTest < ActionDispatch::IntegrationTest
  test "Shared::ExampleComponent renders correctly" do
    get "/examples/index"
    assert_equal 200, status
    assert response.parsed_body.include?('<span title="Hello">World!</span>')
  end
end
