require "test_helper"

class Admin::CategoriesControllerTest < ActionDispatch::IntegrationTest
  test "should redirect to login when not authenticated" do
    get admin_categories_path
    assert_redirected_to root_path
  end

  test "should redirect non-admin users" do
    login_as_customer
    get admin_categories_path
    assert_redirected_to root_path
  end

  test "should index categories" do
    login_as_admin
    get admin_categories_path
    assert_response :success
  end

  test "should show category" do
    login_as_admin
    get admin_category_path(categories(:hardware))
    assert_response :success
  end

  test "should get new category form" do
    login_as_admin
    get new_admin_category_path
    assert_response :success
  end

  test "should create category" do
    login_as_admin
    assert_difference("Category.count") do
      post admin_categories_path, params: {
        category: { name: "New Cat", description: "Test", department_id: departments(:it_support).id }
      }
    end
    assert_redirected_to admin_categories_path
    assert_equal "Category created successfully.", flash[:notice]
  end

  test "should not create invalid category" do
    login_as_admin
    assert_no_difference("Category.count") do
      post admin_categories_path, params: { category: { name: "" } }
    end
    assert_response :unprocessable_entity
  end

  test "should get edit category form" do
    login_as_admin
    get edit_admin_category_path(categories(:hardware))
    assert_response :success
  end

  test "should update category" do
    login_as_admin
    patch admin_category_path(categories(:hardware)), params: { category: { name: "Updated Hardware" } }
    assert_redirected_to admin_categories_path
    assert_equal "Updated Hardware", categories(:hardware).reload.name
  end

  test "should not update with invalid data" do
    login_as_admin
    patch admin_category_path(categories(:hardware)), params: { category: { name: "" } }
    assert_response :unprocessable_entity
  end

  test "should destroy category with no tickets" do
    login_as_admin
    category = Category.create!(name: "Temp Cat", department: departments(:it_support))
    assert_difference("Category.count", -1) do
      delete admin_category_path(category)
    end
    assert_redirected_to admin_categories_path
  end

  test "should not destroy category with tickets" do
    login_as_admin
    assert_no_difference("Category.count") do
      delete admin_category_path(categories(:network))
    end
    assert_redirected_to admin_categories_path
  end
end
