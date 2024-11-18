require "test_helper"

class TagTest < ActiveSupport::TestCase
  test "should normalize tag names" do
    article = articles(:one)
    article.tags = [ Tag.find_or_create("Ruby ON Rails", users(:morty)) ]
    assert_equal "ruby on rails", article.tags.first.name
  end
end
