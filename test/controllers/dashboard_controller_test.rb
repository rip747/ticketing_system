require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  test "should redirect to login when not authenticated" do
    get root_path
    assert_redirected_to login_path
  end

  test "should get dashboard as customer" do
    login_as_customer
    get root_path
    assert_response :success
  end

  test "should get dashboard as admin" do
    login_as_admin
    get root_path
    assert_response :success
  end

  test "should get dashboard as agent" do
    login_as_agent
    get root_path
    assert_response :success
  end

  test "should redirect sys_admin to system dashboard" do
    login_as_sys_admin
    get root_path
    assert_redirected_to system_root_path
  end
end
