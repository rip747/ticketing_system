require "test_helper"

class Admin::DepartmentsControllerTest < ActionDispatch::IntegrationTest
  test "should redirect to login when not authenticated" do
    get admin_departments_path
    assert_redirected_to root_path
  end

  test "should redirect non-admin users" do
    login_as_customer
    get admin_departments_path
    assert_redirected_to root_path
  end

  test "should index departments" do
    login_as_admin
    get admin_departments_path
    assert_response :success
  end

  test "should show department" do
    login_as_admin
    get admin_department_path(departments(:it_support))
    assert_response :success
  end

  test "should get new department form" do
    login_as_admin
    get new_admin_department_path
    assert_response :success
  end

  test "should create department" do
    login_as_admin
    assert_difference("Department.count") do
      post admin_departments_path, params: { department: { name: "New Dept", description: "New department" } }
    end
    assert_redirected_to admin_departments_path
    assert_equal "Department created successfully.", flash[:notice]
  end

  test "should not create invalid department" do
    login_as_admin
    assert_no_difference("Department.count") do
      post admin_departments_path, params: { department: { name: "" } }
    end
    assert_response :unprocessable_entity
  end

  test "should get edit department form" do
    login_as_admin
    get edit_admin_department_path(departments(:it_support))
    assert_response :success
  end

  test "should update department" do
    login_as_admin
    patch admin_department_path(departments(:it_support)), params: { department: { name: "Updated IT" } }
    assert_redirected_to admin_departments_path
    assert_equal "Updated IT", departments(:it_support).reload.name
  end

  test "should not update with invalid data" do
    login_as_admin
    patch admin_department_path(departments(:it_support)), params: { department: { name: "" } }
    assert_response :unprocessable_entity
  end

  test "should destroy department with no dependencies" do
    login_as_admin
    department = Department.create!(name: "Temp Dept", organization: organizations(:default))
    assert_difference("Department.count", -1) do
      delete admin_department_path(department)
    end
    assert_redirected_to admin_departments_path
  end

  test "should not destroy department with users" do
    login_as_admin
    assert_no_difference("Department.count") do
      delete admin_department_path(departments(:it_support))
    end
    assert_redirected_to admin_departments_path
  end
end
