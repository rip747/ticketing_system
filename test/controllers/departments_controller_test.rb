require "test_helper"

class DepartmentsControllerTest < ActionDispatch::IntegrationTest
  test "should redirect to login when not authenticated" do
    department = departments(:it_support)
    get department_categories_path(department)
    assert_redirected_to login_path
  end

  test "should get categories as JSON" do
    login_as_admin
    department = departments(:it_support)
    get department_categories_path(department)
    assert_response :success
    json = response.parsed_body
    assert json.is_a?(Array)
    assert json.all? { |c| c.keys.include?("id") && c.keys.include?("name") }
  end
end
