require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  test "redirects unauthenticated users" do
    get root_url

    assert_redirected_to new_user_session_url
  end
end
