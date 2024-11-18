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
end
