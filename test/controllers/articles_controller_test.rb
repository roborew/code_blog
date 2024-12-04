require "test_helper"
require "ostruct"
require "minitest/mock"

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
      post articles_url, params: {
        article: {
          content: @article.content,
          title: @article.title,
          subheading: @article.subheading,
          publication_date: @article.publication_date
        }
      }
    end
    assert_redirected_to article_url(Article.last)
    assert_equal @user, Article.last.user
  end

  test "should not create article with invalid params" do
    assert_no_difference("Article.count") do
      post articles_url(format: :html),
           params: { article: {
             title: "",
             subheading: @article.subheading,
             content: @article.content,
             publication_date: @article.publication_date
           } }
    end
    assert_response :unprocessable_entity
    assert_template :new
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
    patch article_url(@article), params: {
      article: {
        content: @article.content,
        subheading: @article.subheading,
        publication_date: @article.publication_date,
        title: @article.title
      }
    }
    assert_redirected_to article_url(@article)
  end

  test "should not update article with invalid params" do
    patch article_url(@article), params: { article: { title: "", content: @article.content, publication_date: @article.publication_date } }
    assert_response :unprocessable_entity
    assert_template :edit
  end

  test "should destroy article" do
    assert_difference("Article.count", -1) do
      delete article_url(@article)
    end

    assert_redirected_to articles_url
  end

  test "should create article with tags" do
    assert_difference([ "Article.count", "Tag.count" ], 1) do
      post articles_url(format: :html),
           params: {
             article: {
               title: @article.title,
               content: @article.content,
               publication_date: @article.publication_date
             },
             tags: '[{"value": "newtag"}]'
           }
    end

    assert_redirected_to article_url(Article.last)
    assert_equal [ "newtag" ], Article.last.tags.pluck(:name)
  end

  test "should create article with existing tags" do
    Tag.create!(name: "existingtag", user: @user)

    assert_difference("Article.count", 1) do
      assert_no_difference("Tag.count") do
        post articles_url(format: :html),
             params: {
               article: {
                 title: @article.title,
                 content: @article.content,
                 publication_date: @article.publication_date
               },
               tags: '[{"value": "existingtag"}]'
             }
      end
    end

    assert_redirected_to article_url(Article.last)
    assert_equal [ "existingtag" ], Article.last.tags.pluck(:name)
  end

  test "should create article with multiple tags" do
    assert_difference("Article.count", 1) do
      assert_difference("Tag.count", 2) do
        post articles_url(format: :html),
             params: {
               article: {
                 title: @article.title,
                 content: @article.content,
                 publication_date: @article.publication_date
               },
               tags: '[{"value": "tag1"}, {"value": "tag2"}]'
             }
      end
    end

    assert_redirected_to article_url(Article.last)
    assert_equal [ "tag1", "tag2" ].sort, Article.last.tags.pluck(:name).sort
  end

  test "should preserve tags when article creation fails" do
    assert_no_difference([ "Article.count", "Tag.count" ]) do
      post articles_url(format: :html),
           params: {
             article: {
               title: "", # Invalid title to force failure
               content: @article.content,
               publication_date: @article.publication_date
             },
             tags: '[{"value": "tag1"}, {"value": "tag2"}]'
           }
    end

    assert_response :unprocessable_entity
    assert_template :new
    # Verify that @existing_tags was set correctly
    assert_equal '[{"name":"tag1"},{"name":"tag2"}]', assigns(:existing_tags)
  end

  test "should handle missing tags parameter" do
    post articles_url(format: :html),
         params: {
           article: {
             title: "", # Invalid title to force failure
             content: @article.content,
             publication_date: @article.publication_date
           }
           # Deliberately omitting tags parameter
         }
    assert_response :unprocessable_entity
    assert_template :new
    assert_nil assigns(:existing_tags)
  end

  test "should create article with category" do
    assert_difference([ "Article.count", "Category.count" ], 1) do
      post articles_url(format: :html),
           params: {
             article: {
               title: @article.title,
               content: @article.content,
               publication_date: @article.publication_date
             },
             category: '[{"value": "Newcategory"}]'
           }
    end

    assert_redirected_to article_url(Article.last)
    assert_equal "Newcategory", Article.last.category.name
  end

  test "should create article with existing category" do
    Category.create!(name: "Existingcategory", user: @user)
    assert_difference("Article.count", 1) do
      assert_no_difference("Category.count") do
        post articles_url(format: :html),
             params: {
               article: {
                 title: @article.title,
                 content: @article.content,
                 publication_date: @article.publication_date,
                 status: "published"
               },
               category: '[{"value": "Existingcategory"}]'
             }
      end
    end

    assert_redirected_to article_url(Article.last)
    assert_equal "Existingcategory", Article.last.category.name
  end

  test "should update article category" do
    patch article_url(@article),
          params: {
            article: {
              title: @article.title,
              content: @article.content,
              publication_date: @article.publication_date,
              status: "draft"
            },
            category: '[{"value": "Updatedcategory"}]'
          }

    assert_redirected_to article_url(@article)
    @article.reload
    assert_equal "Updatedcategory", @article.category.name
  end

  test "should remove article category when empty" do
    @article.update!(category: Category.create!(name: "oldcategory", user: @user))

    patch article_url(@article),
          params: {
            article: {
              title: @article.title,
              content: @article.content,
              publication_date: @article.publication_date
            }
            # Deliberately omitting category parameter
          }

    assert_redirected_to article_url(@article)
    @article.reload
    assert_nil @article.category
  end

  test "should create article with status" do
    assert_difference("Article.count") do
      post articles_url, params: {
        article: {
          content: @article.content,
          title: @article.title,
          publication_date: @article.publication_date,
          status: "published"
        }
      }
    end
    assert_redirected_to article_url(Article.last)
    assert_equal "published", Article.last.status
  end

  test "should update article status" do
    patch article_url(@article), params: {
      article: {
        content: @article.content,
        publication_date: @article.publication_date,
        title: @article.title,
        status: "archived"
      }
    }
    assert_redirected_to article_url(@article)
    @article.reload
    assert_equal "archived", @article.status
  end

  test "should filter articles by category" do
    category = Category.create!(name: "TestCategory", user: @user)
    article = Article.create!(title: "Test", content: "Content", user: @user, category: category)

    get articles_url, params: { category: category.id }
    assert_response :success
    assert_includes assigns(:articles), article
  end

  test "should handle redirect for friendly id" do
    # Create and save the article first to ensure it has a slug
    article = Article.create!(
      title: "Original Title",
      content: "Test content",
      user: @user,
      status: "draft"
    )
    old_slug = article.slug

    # Update the title which will generate a new slug
    article.update!(title: "New Title")

    # Try to access using the old slug
    get article_url(old_slug)
    assert_redirected_to article_url(article)
    assert_response :moved_permanently
  end

  test "should revert to previous version" do
    @article.update!(title: "Updated Title")
    original_title = @article.paper_trail.previous_version.title

    post revert_article_url(@article)
    assert_response :success
    assert_equal original_title, assigns(:article).title
    assert_template :edit
  end

  test "should handle revert when no previous version exists" do
    # Ensure there's no previous version
    @article.versions.destroy_all

    post revert_article_url(@article)
    assert_redirected_to edit_article_url(@article)
    assert_equal "No previous version available.", flash[:alert]
  end

  test "should handle turbo stream response for revert" do
    @article.update!(title: "Updated Title")

    post revert_article_url(@article), headers: { "Accept" => "text/vnd.turbo-stream.html" }
    assert_response :success
    assert_match /turbo-stream/, @response.body
  end

  test "should set existing category in edit" do
    category = Category.create!(name: "TestCategory", user: @user)
    @article.update!(category: category)

    get edit_article_url(@article)
    assert_response :success
    assert_equal category.name, assigns(:existing_category)
  end

  test "should handle json format in create" do
    assert_difference("Article.count") do
      post articles_url(format: :json), params: {
        article: {
          title: "Test JSON",
          content: "Content",
          status: "draft"
        }
      }
    end
    assert_response :created
  end

  test "should handle json format in update" do
    patch article_url(@article, format: :json), params: {
      article: {
        title: "Updated via JSON",
        content: @article.content
      }
    }
    assert_response :ok
  end

  test "should handle json format in destroy" do
    delete article_url(@article, format: :json)
    assert_response :no_content
  end
end
