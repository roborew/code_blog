require "test_helper"

class CategoryTest < ActiveSupport::TestCase
  test "should not save category without name" do
    category = Category.new
    assert_not category.save
  end

  test "should not save category with duplicate name" do
    Category.create!(name: "Technology")
    category = Category.new(name: "Technology")
    assert_not category.save
  end

  test "should save valid category" do
    category = Category.new(name: "Technology", description: "Tech articles")
    assert category.save
  end
end
