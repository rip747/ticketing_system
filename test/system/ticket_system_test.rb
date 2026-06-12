require "application_system_test_case"

class TicketSystemTest < ApplicationSystemTestCase
  test "user can log in and see dashboard" do
    login_via_form("john@example.com", "password123")
    assert_current_path root_path
  end

  test "admin can access admin panel" do
    login_via_form("admin@helpdesk.com", "password123")
    visit admin_root_path
    assert page.has_content?("Admin")
  end

  test "customer is redirected from admin panel" do
    login_via_form("john@example.com", "password123")
    visit admin_root_path
    assert_current_path root_path
  end

  test "user can register a new account" do
    visit register_path
    fill_in "Full Name", with: "System Test User"
    fill_in "Email Address", with: "systemtest@example.com"
    fill_in "Password", with: "password123"
    fill_in "Confirm Password", with: "password123"
    click_on "Create Account"

    assert page.has_content?("Account created successfully")
  end

  private

  def login_via_form(email, password)
    visit login_path
    fill_in "Email Address", with: email
    fill_in "Password", with: password
    click_on "Sign In"
  end
end
