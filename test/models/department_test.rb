require "test_helper"

class DepartmentTest < ActiveSupport::TestCase
  test "should be valid with valid attributes" do
    department = Department.new(name: "Support", description: "Support department")
    assert department.valid?
  end

  test "should require name" do
    department = Department.new
    assert_not department.valid?
    assert_includes department.errors[:name], "can't be blank"
  end

  test "should require unique name" do
    department = Department.new(name: departments(:it_support).name)
    assert_not department.valid?
    assert_includes department.errors[:name], "has already been taken"
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
    department = Department.create!(name: "Temp Dept", description: "Temporary")
    department.categories.create!(name: "Temp Category")
    assert_difference("Category.count", -1) do
      department.destroy
    end
  end

  test "destroy should be restricted when tickets exist" do
    department = departments(:it_support)
    assert_not department.destroy
  end
end
