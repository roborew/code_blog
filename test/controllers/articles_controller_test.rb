require "test_helper"

class ArticlesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:morty)
    sign_in @user
    @article = articles(:one)
  end

  test "should get index" do
    get articles_url
    assert_response :success
  end

  test "should get new if signed in" do
    get new_article_url
    assert_response :success
  end

  test "should not get new if not signed in" do
    sign_out users(:morty)
    get new_article_url
    assert_response :redirect
  end

  test "should create article" do
    assert_difference("Article.count") do
      post articles_url, params: { article: { content: @article.content, title: @article.title, publicate_date: @article.publication_date }  }
    end
    assert_redirected_to article_url(Article.last)
    assert_equal @user, Article.last.user
  end

  test "should show article" do
    get article_url(@article)
    assert_response :success
  end

  test "should get edit if signed in" do
    get edit_article_url(@article)
    assert_response :success
  end

  test "should not get edit if not signed in" do
    sign_out @user
    get edit_article_url(@article)
    assert_response :redirect
  end

  test "should update article" do
    patch article_url(@article), params: { article: { content: @article.content, publication_date: @article.publication_date, title: @article.title } }
    assert_redirected_to article_url(@article)
  end

  test "should destroy article" do
    assert_difference("Article.count", -1) do
      delete article_url(@article)
    end

    assert_redirected_to articles_url
  end
end
