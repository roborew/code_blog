require "test_helper"

class CategoryTest < ActiveSupport::TestCase
  def setup
    @user = users(:morty)
  end
  test "should not save category without name" do
    category = Category.new
    assert_not category.save
  end

  test "should not save category with duplicate name" do
    Category.create!(name: "Technology", user: users(:morty))
    category = Category.new(name: "Technology", user: users(:morty))
    assert_not category.save
  end

  test "should save valid category" do
    category = Category.new(name: "Technology", description: "Tech articles", user: users(:morty))
    assert category.save
  end

  test "should return existing category if it exists" do
    existing_category = Category.create(name: "Tech", user: @user)
    category = Category.find_or_create("Tech", @user)
    assert_equal existing_category, category
  end

  test "should create a new category if it does not exist" do
    assert_difference "Category.count", 1 do
      Category.find_or_create("Health", @user)
    end

    category = Category.find_by(name: "Health", user: @user)
    assert_not_nil category
    assert_equal "Health", category.name
    assert_equal @user, category.user
  end
end
