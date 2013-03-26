require 'test_helper'

class GamesControllerTest < ActionController::TestCase
  test "should get home" do
    get :home
    assert_response :success
  end

  test "should get play" do
    get :play
    assert_response :success
  end

end
