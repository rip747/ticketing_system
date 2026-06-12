require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "should get login page" do
    get login_path
    assert_response :success
  end

  test "should redirect to root if already logged in" do
    login_as_customer
    get login_path
    assert_redirected_to root_path
  end

  test "should log in with valid credentials" do
    user = users(:customer_john)
    post login_path, params: { email: user.email, password: "password123" }
    assert_redirected_to root_path
    assert_equal user.id, session[:user_id]
  end

  test "should reject invalid credentials" do
    post login_path, params: { email: "wrong@example.com", password: "wrong" }
    assert_response :unprocessable_entity
    assert_nil session[:user_id]
  end

  test "should reject wrong password" do
    post login_path, params: { email: users(:customer_john).email, password: "wrongpassword" }
    assert_response :unprocessable_entity
    assert_nil session[:user_id]
  end

  test "should log out" do
    login_as_customer
    delete logout_path
    assert_redirected_to login_path
    assert_nil session[:user_id]
  end
end
