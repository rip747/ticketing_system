require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :rack_test

  def login_via_form(email, password)
    visit login_path
    fill_in "Email", with: email
    fill_in "Password", with: password
    click_on "Log In"
  end
end
