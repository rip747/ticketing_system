require "test_helper"

class Admin::DashboardControllerTest < ActionDispatch::IntegrationTest
  test "should redirect to login when not authenticated" do
    get admin_root_path
    assert_redirected_to root_path
  end

  test "should redirect non-admin users" do
    login_as_customer
    get admin_root_path
    assert_redirected_to root_path
  end

  test "should redirect agents" do
    login_as_agent
    get admin_root_path
    assert_redirected_to root_path
  end

  test "should get dashboard as admin" do
    login_as_admin
    get admin_root_path
    assert_response :success
  end
end
