require 'test_helper'

class CheckTimeControllerTest < ActionDispatch::IntegrationTest
  test "should get now" do
    get '/time'
    assert_response :success
  end
end
