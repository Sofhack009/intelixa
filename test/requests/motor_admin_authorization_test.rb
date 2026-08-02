require "test_helper"

class MotorAdminAuthorizationTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "operator cannot access Motor Admin" do
    sign_in users(:operator)

    get "/motor_admin"

    assert_response :not_found
  end

  test "admin can access Motor Admin route" do
    sign_in users(:admin)

    get "/motor_admin"

    assert_response :success
  end
end
