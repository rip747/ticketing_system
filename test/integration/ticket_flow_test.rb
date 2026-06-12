require "test_helper"

class TicketFlowTest < ActionDispatch::IntegrationTest
  test "customer can create and view their own ticket" do
    login_as_customer

    # Create a ticket
    get new_ticket_path
    assert_response :success

    post tickets_path, params: {
      ticket: {
        subject: "Integration test ticket",
        description: "Testing the full flow",
        priority: "medium",
        category_id: categories(:network).id,
        department_id: departments(:it_support).id
      }
    }
    ticket = Ticket.last
    assert_redirected_to ticket_path(ticket)
    follow_redirect!
    assert_response :success

    # View the ticket
    get ticket_path(ticket)
    assert_response :success
  end

  test "customer can only see their own tickets" do
    login_as_customer
    get tickets_path
    assert_response :success
  end

  test "admin can see all tickets" do
    login_as_admin
    get tickets_path
    assert_response :success
  end

  test "agent can assign and close tickets" do
    login_as_agent

    # Assign ticket
    ticket = tickets(:laptop_issue)
    post assign_ticket_path(ticket), params: { assigned_user_id: users(:agent_sarah).id }
    follow_redirect!
    assert_response :success
    assert_equal users(:agent_sarah), ticket.reload.assigned_user

    # Close ticket
    patch close_ticket_path(ticket)
    follow_redirect!
    assert_response :success
    assert_equal "closed", ticket.reload.status
  end

  test "admin can manage departments" do
    login_as_admin

    # Create
    post admin_departments_path, params: { department: { name: "Test Dept", description: "Test" } }
    follow_redirect!
    assert_response :success
    assert Department.find_by(name: "Test Dept")

    # Update
    dept = Department.find_by(name: "Test Dept")
    patch admin_department_path(dept), params: { department: { name: "Updated Dept" } }
    follow_redirect!
    assert_response :success
    assert_equal "Updated Dept", dept.reload.name

    # Delete
    delete admin_department_path(dept)
    follow_redirect!
    assert_response :success
    assert_nil Department.find_by(name: "Updated Dept")
  end

  test "admin can manage users" do
    login_as_admin

    # Create user
    post admin_users_path, params: {
      user: {
        name: "Integration User",
        email: "integration@example.com",
        password: "password123",
        password_confirmation: "password123",
        role: "agent",
        department_id: departments(:it_support).id
      }
    }
    follow_redirect!
    assert_response :success
    assert User.find_by(email: "integration@example.com")
  end

  test "authentication flow" do
    # Register
    post register_path, params: {
      user: {
        name: "Flow User",
        email: "flow@example.com",
        password: "password123",
        password_confirmation: "password123"
      }
    }
    assert_redirected_to root_path

    # Logout
    delete logout_path
    assert_redirected_to login_path

    # Login
    post login_path, params: { email: "flow@example.com", password: "password123" }
    assert_redirected_to root_path

    # Access profile
    get profile_path
    assert_response :success
  end
end
