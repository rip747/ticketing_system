require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  test "should get registration page" do
    get register_path
    assert_response :success
  end

  test "should register new user with organization" do
    assert_difference([ "User.count", "Organization.count" ]) do
      post register_path, params: {
        user: {
          organization_name: "My Company",
          name: "New User",
          email: "newuser@example.com",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end
    assert_redirected_to root_path
    assert_equal "Organization created successfully! Welcome, New User.", flash[:notice]

    user = User.find_by(email: "newuser@example.com")
    assert_not_nil user
    assert_equal "org_admin", user.role
    assert_equal "my-company", user.organization.slug
  end

  test "should not register without organization name" do
    assert_no_difference([ "User.count", "Organization.count" ]) do
      post register_path, params: {
        user: {
          name: "New User",
          email: "newuser@example.com",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end
    assert_response :unprocessable_entity
  end

  test "should not register with invalid data" do
    assert_no_difference([ "User.count", "Organization.count" ]) do
      post register_path, params: {
        user: {
          organization_name: "Company",
          name: "",
          email: "invalid",
          password: "short",
          password_confirmation: "mismatch"
        }
      }
    end
    assert_response :unprocessable_entity
  end

  test "should reject duplicate email globally" do
    assert_no_difference([ "User.count", "Organization.count" ]) do
      post register_path, params: {
        user: {
          organization_name: "Another Company",
          name: "Duplicate Email",
          email: users(:customer_john).email,
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end
    assert_response :unprocessable_entity
  end

  test "should create user as org_admin role (first user of organization)" do
    post register_path, params: {
      user: {
        organization_name: "Brand New Co",
        name: "Founder User",
        email: "founder@example.com",
        password: "password123",
        password_confirmation: "password123"
      }
    }
    user = User.find_by(email: "founder@example.com")
    assert_equal "org_admin", user.role
  end

  test "should redirect to login for profile when not logged in" do
    get profile_path
    assert_redirected_to login_path
  end

  test "should show profile when logged in" do
    login_as_customer
    get profile_path
    assert_response :success
  end

  test "should get edit profile when logged in" do
    login_as_customer
    get edit_profile_path
    assert_response :success
  end

  test "should update profile" do
    login_as_customer
    patch profile_path, params: { user: { name: "Updated Name" } }
    assert_redirected_to profile_path
    assert_equal "Profile updated successfully.", flash[:notice]
    assert_equal "Updated Name", users(:customer_john).reload.name
  end

  test "should not update profile with invalid data" do
    login_as_customer
    patch profile_path, params: { user: { name: "" } }
    assert_response :unprocessable_entity
  end
end
