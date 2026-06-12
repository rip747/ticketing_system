require "test_helper"

class DepartmentTest < ActiveSupport::TestCase
  test "should be valid with valid attributes" do
    department = Department.new(name: "Support", description: "Support department", organization: organizations(:default))
    assert department.valid?
  end

  test "should require name" do
    department = Department.new(organization: organizations(:default))
    assert_not department.valid?
    assert_includes department.errors[:name], "can't be blank"
  end

  test "should require unique name scoped to organization" do
    department = Department.new(name: departments(:it_support).name, organization: organizations(:default))
    assert_not department.valid?
    assert_includes department.errors[:name], "has already been taken"
  end

  test "should allow same name in different organization" do
    other_org = Organization.create!(name: "Other Org", slug: "other-org")
    department = Department.new(name: departments(:it_support).name, organization: other_org)
    assert department.valid?
  end

  test "should have many users" do
    department = departments(:it_support)
    assert_respond_to department, :users
    assert department.users.include?(users(:admin))
  end

  test "should have many categories" do
    department = departments(:it_support)
    assert_respond_to department, :categories
    assert_includes department.categories, categories(:hardware)
    assert_includes department.categories, categories(:software)
    assert_includes department.categories, categories(:network)
  end

  test "should have many tickets" do
    department = departments(:it_support)
    assert_respond_to department, :tickets
    assert department.tickets.include?(tickets(:vpn_issue))
  end

  test "destroy should be restricted when users exist" do
    department = departments(:it_support)
    assert_not department.destroy
    assert_includes department.errors[:base], "Cannot delete record because dependent users exist"
  end

  test "destroy should cascade to categories when no tickets block" do
    department = Department.create!(name: "Temp Dept", description: "Temporary", organization: organizations(:default))
    department.categories.create!(name: "Temp Category", organization: organizations(:default))
    assert_difference("Category.count", -1) do
      department.destroy
    end
  end

  test "destroy should be restricted when tickets exist" do
    department = departments(:it_support)
    assert_not department.destroy
  end
end
