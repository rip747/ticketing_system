require "test_helper"

class CategoryTest < ActiveSupport::TestCase
  test "should be valid with valid attributes" do
    category = Category.new(name: "New Category", department: departments(:it_support), organization: organizations(:default))
    assert category.valid?
  end

  test "should require name" do
    category = Category.new(department: departments(:it_support), organization: organizations(:default))
    assert_not category.valid?
    assert_includes category.errors[:name], "can't be blank"
  end

  test "should belong to organization" do
    category = categories(:hardware)
    assert_respond_to category, :organization
    assert_equal organizations(:default), category.organization
  end

  test "should require unique name scoped to department" do
    duplicate = Category.new(
      name: categories(:hardware).name,
      department: departments(:it_support),
      organization: organizations(:default)
    )
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:name], "has already been taken"
  end

  test "should allow same name in different departments" do
    duplicate = Category.new(
      name: categories(:hardware).name,
      department: departments(:hr),
      organization: organizations(:default)
    )
    assert duplicate.valid?
  end

  test "should belong to department" do
    category = categories(:hardware)
    assert_respond_to category, :department
    assert_equal departments(:it_support), category.department
  end

  test "should have many tickets" do
    category = categories(:network)
    assert_respond_to category, :tickets
    assert category.tickets.include?(tickets(:vpn_issue))
  end

  test "destroy should be restricted when tickets exist" do
    category = categories(:network)
    assert_not category.destroy
  end

  test "destroy should work when no tickets exist" do
    category = Category.create!(name: "Temp Category", department: departments(:it_support), organization: organizations(:default))
    assert_difference("Category.count", -1) do
      category.destroy
    end
  end
end
