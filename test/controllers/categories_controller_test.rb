require "test_helper"

class CategoriesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = User.create(email: "test@example.com", password: "password")
    sign_in @user
    @category1 = Category.create(name: "Tech", user: @user)
    @category2 = Category.create(name: "Health", user: @user)
    @category3 = Category.create(name: "Tech", user: nil) # Public category
  end

  test "should get index" do
    get categories_path
    assert_response :success
  end

  test "should get edit" do
    get edit_category_path(@category1)
    assert_response :success
  end

  test "should return matching categories for the current user" do
    get search_categories_path, params: { q: "Tech" }
    assert_response :success

    categories = JSON.parse(response.body)
    assert_includes categories, "Tech"
    assert_not_includes categories, "Health"
  end

  test "should limit results to 10 categories" do
    11.times { |i| Category.create(name: "Category#{i}", user: @user) }
    get search_categories_path, params: { q: "Category" }
    assert_response :success

    categories = JSON.parse(response.body)
    assert_equal 10, categories.length
  end
end
