require "test_helper"

class DepartmentsControllerTest < ActionDispatch::IntegrationTest
  test "should get categories as JSON" do
    department = departments(:it_support)
    get department_categories_path(department)
    assert_response :success
    json = response.parsed_body
    assert json.is_a?(Array)
    assert json.all? { |c| c.keys.include?("id") && c.keys.include?("name") }
  end
end
