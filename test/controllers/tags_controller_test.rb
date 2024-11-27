require "test_helper"

class TagsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = User.create(email: "test@example.com", password: "password")
    sign_in @user
    @tag1 = Tag.create(name: "Ruby", user: @user)
    @tag2 = Tag.create(name: "Rails", user: @user)
    @tag3 = Tag.create(name: "Ruby", user: nil) # Public tag
  end

  test "should return matching tags for the current user" do
    get tags_search_path, params: { q: "Ruby" }
    assert_response :success

    tags = JSON.parse(response.body)
    assert_includes tags, "Ruby"
    assert_not_includes tags, "Rails"
  end

  test "should limit results to 10 tags" do
    11.times { |i| Tag.create(name: "Tag#{i}", user: @user) }
    get tags_search_path, params: { q: "Tag" }
    assert_response :success

    tags = JSON.parse(response.body)
    assert_equal 10, tags.length
  end
end
