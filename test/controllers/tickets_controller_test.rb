require "test_helper"

class TicketsControllerTest < ActionDispatch::IntegrationTest
  # Authentication tests
  test "should redirect to login when not authenticated" do
    get tickets_path
    assert_redirected_to login_path
  end

  test "should redirect to login for new ticket" do
    get new_ticket_path
    assert_redirected_to login_path
  end

  test "should redirect to login for show" do
    get ticket_path(tickets(:vpn_issue))
    assert_redirected_to login_path
  end

  # Index
  test "should list tickets for customer (own tickets only)" do
    login_as_customer
    get tickets_path
    assert_response :success
  end

  test "should list all tickets for admin" do
    login_as_admin
    get tickets_path
    assert_response :success
  end

  test "should filter tickets by status" do
    login_as_admin
    get tickets_path, params: { status: "open" }
    assert_response :success
  end

  test "should filter tickets by priority" do
    login_as_admin
    get tickets_path, params: { priority: "high" }
    assert_response :success
  end

  test "should filter tickets by department" do
    login_as_admin
    get tickets_path, params: { department_id: departments(:it_support).id }
    assert_response :success
  end

  test "should search tickets" do
    login_as_admin
    get tickets_path, params: { q: "VPN" }
    assert_response :success
  end

  # Show
  test "should show ticket" do
    login_as_admin
    get ticket_path(tickets(:vpn_issue))
    assert_response :success
  end

  # New
  test "should get new ticket form" do
    login_as_customer
    get new_ticket_path
    assert_response :success
  end

  # Create
  test "should create ticket" do
    login_as_customer
    assert_difference("Ticket.count") do
      post tickets_path, params: {
        ticket: {
          subject: "New test ticket",
          description: "This is a test ticket description for testing",
          priority: "medium",
          category_id: categories(:network).id,
          department_id: departments(:it_support).id
        }
      }
    end
    assert_redirected_to ticket_path(Ticket.last)
    assert_equal "Ticket created successfully.", flash[:notice]
    assert_equal "open", Ticket.last.status
    assert_equal users(:customer_john), Ticket.last.user
  end

  test "should not create invalid ticket" do
    login_as_customer
    assert_no_difference("Ticket.count") do
      post tickets_path, params: { ticket: { subject: "" } }
    end
    assert_response :unprocessable_entity
  end

  # Edit / Update (agent/admin only)
  test "should not get edit as customer" do
    login_as_customer
    get edit_ticket_path(tickets(:vpn_issue))
    assert_redirected_to root_path
  end

  test "should get edit as admin" do
    login_as_admin
    get edit_ticket_path(tickets(:vpn_issue))
    assert_response :success
  end

  test "should get edit as agent" do
    login_as_agent
    get edit_ticket_path(tickets(:vpn_issue))
    assert_response :success
  end

  test "should update ticket as admin" do
    login_as_admin
    patch ticket_path(tickets(:vpn_issue)), params: { ticket: { subject: "Updated subject" } }
    assert_redirected_to ticket_path(tickets(:vpn_issue))
    assert_equal "Updated subject", tickets(:vpn_issue).reload.subject
  end

  test "should not update ticket as customer" do
    login_as_customer
    patch ticket_path(tickets(:vpn_issue)), params: { ticket: { subject: "Hacked" } }
    assert_redirected_to root_path
  end

  test "should not update with invalid data" do
    login_as_admin
    patch ticket_path(tickets(:vpn_issue)), params: { ticket: { subject: "" } }
    assert_response :unprocessable_entity
  end

  # Destroy
  test "should destroy ticket as admin" do
    login_as_admin
    assert_difference("Ticket.count", -1) do
      delete ticket_path(tickets(:email_issue))
    end
    assert_redirected_to tickets_path
  end

  test "should not destroy ticket as customer" do
    login_as_customer
    assert_no_difference("Ticket.count") do
      delete ticket_path(tickets(:vpn_issue))
    end
    assert_redirected_to root_path
  end

  # Assign
  test "should assign ticket as admin" do
    login_as_admin
    agent = users(:agent_sarah)
    post assign_ticket_path(tickets(:laptop_issue)), params: { assigned_user_id: agent.id }
    assert_redirected_to ticket_path(tickets(:laptop_issue))
    assert_equal agent, tickets(:laptop_issue).reload.assigned_user
  end

  test "should not assign ticket as customer" do
    login_as_customer
    agent = users(:agent_sarah)
    post assign_ticket_path(tickets(:laptop_issue)), params: { assigned_user_id: agent.id }
    assert_redirected_to root_path
  end

  test "should show alert when assign fails on non-open ticket" do
    login_as_admin
    ticket = tickets(:payroll_issue) # status is pending, not open
    post assign_ticket_path(ticket), params: { assigned_user_id: users(:agent_sarah).id }
    assert_redirected_to ticket_path(ticket)
    assert_equal "Could not assign ticket.", flash[:alert]
  end

  # Close
  test "should close ticket" do
    login_as_admin
    patch close_ticket_path(tickets(:vpn_issue))
    assert_redirected_to ticket_path(tickets(:vpn_issue))
    assert_equal "closed", tickets(:vpn_issue).reload.status
    assert_not_nil tickets(:vpn_issue).closed_at
  end

  # Reopen
  test "should reopen ticket" do
    login_as_admin
    patch reopen_ticket_path(tickets(:license_request))
    assert_redirected_to ticket_path(tickets(:license_request))
    assert_equal "open", tickets(:license_request).reload.status
    assert_nil tickets(:license_request).closed_at
  end
end
