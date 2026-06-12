require "test_helper"

class Admin::UsersControllerTest < ActionDispatch::IntegrationTest
  test "should redirect to login when not authenticated" do
    get admin_users_path
    assert_redirected_to root_path
  end

  test "should redirect non-admin users" do
    login_as_customer
    get admin_users_path
    assert_redirected_to root_path
  end

  test "should index users" do
    login_as_admin
    get admin_users_path
    assert_response :success
  end

  test "should filter users by role" do
    login_as_admin
    get admin_users_path, params: { role: "agent" }
    assert_response :success
  end

  test "should show user" do
    login_as_admin
    get admin_user_path(users(:customer_john))
    assert_response :success
  end

  test "should get new user form" do
    login_as_admin
    get new_admin_user_path
    assert_response :success
  end

  test "should create user" do
    login_as_admin
    assert_difference("User.count") do
      post admin_users_path, params: {
        user: {
          name: "New User",
          email: "new-user@helpdesk.com",
          password: "password123",
          password_confirmation: "password123",
          role: "agent",
          department_id: departments(:it_support).id
        }
      }
    end
    assert_redirected_to admin_users_path
    assert_equal "User created successfully.", flash[:notice]
  end

  test "should not create invalid user" do
    login_as_admin
    assert_no_difference("User.count") do
      post admin_users_path, params: { user: { name: "", email: "" } }
    end
    assert_response :unprocessable_entity
  end

  test "should get edit user form" do
    login_as_admin
    get edit_admin_user_path(users(:customer_john))
    assert_response :success
  end

  test "should update user" do
    login_as_admin
    patch admin_user_path(users(:customer_john)), params: { user: { name: "Updated Name" } }
    assert_redirected_to admin_users_path
    assert_equal "Updated Name", users(:customer_john).reload.name
  end

  test "should update user without password change" do
    login_as_admin
    patch admin_user_path(users(:customer_john)), params: {
      user: { name: "New Name", password: "", password_confirmation: "" }
    }
    assert_redirected_to admin_users_path
    assert_equal "New Name", users(:customer_john).reload.name
  end

  test "should not update with invalid data" do
    login_as_admin
    patch admin_user_path(users(:customer_john)), params: { user: { name: "" } }
    assert_response :unprocessable_entity
  end

  test "should not destroy user with tickets" do
    login_as_admin
    user = users(:customer_john) # has tickets
    assert_no_difference("User.count") do
      delete admin_user_path(user)
    end
    assert_redirected_to admin_users_path
    assert flash[:alert].present?
  end

  test "should destroy user" do
    login_as_admin
    user = User.create!(
      name: "Temp",
      email: "temp@example.com",
      password: "password123",
      role: "customer",
      organization: organizations(:default)
    )
    assert_difference("User.count", -1) do
      delete admin_user_path(user)
    end
    assert_redirected_to admin_users_path
  end
end
