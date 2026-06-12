require "test_helper"

class TicketTest < ActiveSupport::TestCase
  test "should be valid with valid attributes" do
    ticket = Ticket.new(
      subject: "Test ticket",
      status: "open",
      priority: "medium",
      user: users(:customer_john),
      category: categories(:network),
      department: departments(:it_support)
    )
    ticket.description = "This is a test ticket description"
    assert ticket.valid?
  end

  test "should require subject" do
    ticket = Ticket.new(
      status: "open",
      priority: "medium",
      user: users(:customer_john),
      category: categories(:network),
      department: departments(:it_support)
    )
    assert_not ticket.valid?
    assert_includes ticket.errors[:subject], "can't be blank"
  end

  test "should require description" do
    ticket = Ticket.new(
      subject: "Test",
      status: "open",
      priority: "medium",
      user: users(:customer_john),
      category: categories(:network),
      department: departments(:it_support)
    )
    assert_not ticket.valid?
    assert_includes ticket.errors[:description], "can't be blank"
  end

  test "should validate status inclusion" do
    ticket = Ticket.new(
      subject: "Test",
      status: "invalid",
      priority: "medium",
      user: users(:customer_john),
      category: categories(:network),
      department: departments(:it_support)
    )
    assert_not ticket.valid?
    assert_includes ticket.errors[:status], "is not included in the list"
  end

  test "should validate priority inclusion" do
    ticket = Ticket.new(
      subject: "Test",
      status: "open",
      priority: "invalid",
      user: users(:customer_john),
      category: categories(:network),
      department: departments(:it_support)
    )
    assert_not ticket.valid?
    assert_includes ticket.errors[:priority], "is not included in the list"
  end

  test "should belong to user" do
    ticket = tickets(:vpn_issue)
    assert_respond_to ticket, :user
    assert_equal users(:customer_john), ticket.user
  end

  test "should belong to assigned_user (optional)" do
    ticket = tickets(:vpn_issue)
    assert_respond_to ticket, :assigned_user
    assert_equal users(:agent_sarah), ticket.assigned_user
  end

  test "should allow assigned_user to be nil" do
    ticket = tickets(:laptop_issue)
    assert_nil ticket.assigned_user
  end

  test "should belong to category" do
    ticket = tickets(:vpn_issue)
    assert_respond_to ticket, :category
    assert_equal categories(:network), ticket.category
  end

  test "should belong to department" do
    ticket = tickets(:vpn_issue)
    assert_respond_to ticket, :department
    assert_equal departments(:it_support), ticket.department
  end

  test "should have many comments" do
    ticket = tickets(:vpn_issue)
    assert_respond_to ticket, :comments
    assert ticket.comments.include?(comments(:comment_one))
  end

  test "should have rich text description" do
    ticket = tickets(:vpn_issue)
    assert_respond_to ticket, :description
    assert ticket.description.body.present?
  end

  test "scope open returns open tickets" do
    assert Ticket.open.all? { |t| t.status == "open" }
    assert_includes Ticket.open, tickets(:vpn_issue)
    assert_not_includes Ticket.open, tickets(:payroll_issue)
  end

  test "scope pending returns pending tickets" do
    assert Ticket.pending.all? { |t| t.status == "pending" }
    assert_includes Ticket.pending, tickets(:payroll_issue)
  end

  test "scope resolved returns resolved tickets" do
    assert Ticket.resolved.all? { |t| t.status == "resolved" }
    assert_includes Ticket.resolved, tickets(:license_request)
  end

  test "scope closed returns closed tickets" do
    assert Ticket.closed.all? { |t| t.status == "closed" }
  end

  test "scope by_status filters by status" do
    assert_equal 5, Ticket.by_status("open").count
    assert_equal 2, Ticket.by_status("pending").count
    assert_equal 1, Ticket.by_status("resolved").count
    assert_equal Ticket.all.count, Ticket.by_status(nil).count
  end

  test "scope by_priority filters by priority" do
    assert_equal 2, Ticket.by_priority("high").count
    assert_equal 3, Ticket.by_priority("medium").count
    assert_equal 1, Ticket.by_priority("urgent").count
    assert_equal Ticket.all.count, Ticket.by_priority(nil).count
  end

  test "scope by_department filters by department" do
    assert_equal 3, Ticket.by_department(departments(:it_support).id).count
    assert_equal 2, Ticket.by_department(departments(:hr).id).count
    assert_equal Ticket.all.count, Ticket.by_department(nil).count
  end

  test "scope recent orders by updated_at desc" do
    tickets = Ticket.recent
    assert_equal Ticket.order(updated_at: :desc).pluck(:id), tickets.pluck(:id)
  end

  test "scope unassigned returns tickets without assigned user" do
    assert Ticket.unassigned.all? { |t| t.assigned_user_id.nil? }
    assert_includes Ticket.unassigned, tickets(:laptop_issue)
    assert_not_includes Ticket.unassigned, tickets(:vpn_issue)
  end

  test "open? returns true when status is open" do
    assert tickets(:vpn_issue).open?
    assert_not tickets(:license_request).open?
  end

  test "pending? returns true when status is pending" do
    assert tickets(:payroll_issue).pending?
    assert_not tickets(:vpn_issue).pending?
  end

  test "resolved? returns true when status is resolved" do
    assert tickets(:license_request).resolved?
    assert_not tickets(:vpn_issue).resolved?
  end

  test "closed? returns true when status is closed" do
    assert_not tickets(:vpn_issue).closed?
  end

  test "close! sets status to closed and records closed_at" do
    ticket = tickets(:vpn_issue)
    ticket.close!
    assert_equal "closed", ticket.status
    assert_not_nil ticket.closed_at
  end

  test "assign_to! assigns user and sets pending if open" do
    ticket = tickets(:laptop_issue)
    agent = users(:agent_sarah)
    ticket.assign_to!(agent)
    assert_equal agent, ticket.assigned_user
    assert_equal "pending", ticket.status
  end

  test "assign_to! does not reassign if not open" do
    ticket = tickets(:payroll_issue)
    original_assignee = ticket.assigned_user
    agent = users(:agent_sarah)
    ticket.assign_to!(agent)
    # Assign only happens if status is open; payroll_issue is pending
    assert_equal original_assignee, ticket.assigned_user
    assert_equal "pending", ticket.status
  end

  test "destroy cascades to comments" do
    ticket = tickets(:vpn_issue)
    assert_difference("Comment.count", -2) do
      ticket.destroy
    end
  end
end
