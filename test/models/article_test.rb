require "test_helper"

class ArticleTest < ActiveSupport::TestCase
  test "should not save article without title" do
    article = Article.new(content: "Some content")
    assert_not article.save
    assert_includes article.errors[:title], "can't be blank"
  end

  test "should not save article without content" do
    article = Article.new(title: "Some content")
    assert_not article.save
    assert_includes article.errors[:content], "can't be blank"
  end

  test "can be created without category" do
    article = Article.new(title: "Test", content: "Content", user: users(:morty), status: "draft")
    assert article.valid?
  end

  test "can be associated with category" do
    category = Category.new(name: "Technology", user: users(:morty))
    assert category.valid?, "Category is invalid: #{category.errors.full_messages}"
    category.save!

    article = Article.new(title: "Test", content: "Content", category: category, user: users(:morty), status: "published")
    assert article.valid?, "Article is invalid: #{article.errors.full_messages}"
    assert_equal "Technology", article.category.name
  end

  test "should default status to draft" do
    article = Article.new(title: "Test", content: "Content", user: users(:morty))
    assert_equal "draft", article.status
  end

  test "can be created with valid status" do
    article = Article.new(title: "Test", content: "Content", user: users(:morty), status: "draft")
    assert article.valid?
    assert_equal "draft", article.status
  end

  test "cannot be created with invalid status" do
    article = Article.new(title: "Test", content: "Content", user: users(:morty), status: "invalid")
    assert_not article.valid?
    assert_includes article.errors[:status], "is not included in the list"
  end
end
