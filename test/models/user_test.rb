require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "should be valid with valid attributes" do
    user = User.new(
      name: "Test User",
      email: "test@example.com",
      password: "password123",
      password_confirmation: "password123",
      role: "customer"
    )
    assert user.valid?
  end

  test "should require name" do
    user = User.new(email: "test@example.com", password: "password123", role: "customer")
    assert_not user.valid?
    assert_includes user.errors[:name], "can't be blank"
  end

  test "should require email" do
    user = User.new(name: "Test", password: "password123", role: "customer")
    assert_not user.valid?
    assert_includes user.errors[:email], "can't be blank"
  end

  test "should require unique email" do
    user = User.new(
      name: "Test",
      email: users(:admin).email,
      password: "password123",
      role: "customer"
    )
    assert_not user.valid?
    assert_includes user.errors[:email], "has already been taken"
  end

  test "should validate email format" do
    user = User.new(
      name: "Test",
      email: "invalid-email",
      password: "password123",
      role: "customer"
    )
    assert_not user.valid?
    assert_includes user.errors[:email], "is invalid"
  end

  test "should validate role inclusion" do
    user = User.new(
      name: "Test",
      email: "test@example.com",
      password: "password123",
      role: "superadmin"
    )
    assert_not user.valid?
    assert_includes user.errors[:role], "is not included in the list"
  end

  test "should default role to customer" do
    user = User.new(
      name: "Test",
      email: "test-default@example.com",
      password: "password123"
    )
    assert_equal "customer", user.role
  end

  test "should authenticate with valid password" do
    user = users(:admin)
    assert user.authenticate("password123")
  end

  test "should not authenticate with invalid password" do
    user = users(:admin)
    assert_not user.authenticate("wrongpassword")
  end

  test "should belong to department (optional)" do
    user = users(:admin)
    assert_respond_to user, :department
    assert_equal departments(:it_support), user.department
  end

  test "should allow department to be nil" do
    user = User.create!(
      name: "No Dept",
      email: "nodept@example.com",
      password: "password123",
      role: "customer"
    )
    assert_nil user.department
  end

  test "should have many tickets" do
    user = users(:customer_john)
    assert_respond_to user, :tickets
    assert user.tickets.include?(tickets(:vpn_issue))
  end

  test "should have many assigned_tickets" do
    user = users(:agent_sarah)
    assert_respond_to user, :assigned_tickets
    assert user.assigned_tickets.include?(tickets(:vpn_issue))
  end

  test "should have many comments" do
    user = users(:agent_sarah)
    assert_respond_to user, :comments
    assert user.comments.include?(comments(:comment_one))
  end

  test "scope agents returns only agents" do
    agents = User.agents
    assert agents.all? { |u| u.role == "agent" }
    assert_includes agents, users(:agent_sarah)
    assert_not_includes agents, users(:admin)
  end

  test "scope admins returns only admins" do
    admins = User.admins
    assert admins.all? { |u| u.role == "admin" }
    assert_includes admins, users(:admin)
    assert_not_includes admins, users(:agent_sarah)
  end

  test "scope customers returns only customers" do
    customers = User.customers
    assert customers.all? { |u| u.role == "customer" }
    assert_includes customers, users(:customer_john)
    assert_not_includes customers, users(:admin)
  end

  test "agent_or_admin? returns true for agents" do
    assert users(:agent_sarah).agent_or_admin?
  end

  test "agent_or_admin? returns true for admins" do
    assert users(:admin).agent_or_admin?
  end

  test "agent_or_admin? returns false for customers" do
    assert_not users(:customer_john).agent_or_admin?
  end

  test "admin? returns true for admins" do
    assert users(:admin).admin?
  end

  test "admin? returns false for agents" do
    assert_not users(:agent_sarah).admin?
  end

  test "customer? returns true for customers" do
    assert users(:customer_john).customer?
  end

  test "customer? returns false for agents" do
    assert_not users(:agent_sarah).customer?
  end
end
