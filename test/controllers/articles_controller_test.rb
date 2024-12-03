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

  def test_process_inline_images_with_existing_file
    content_with_image = "![alt text](https://example.com/temp-file/sample.jpg)"
    file_path = Rails.root.join("tmp/uploads/sample.jpg")

    # Get controller instance
    get articles_url
    @controller = @controller.class.new
    @controller.instance_variable_set(:@article, @article)

    # Mock file system operations
    path_mock = Minitest::Mock.new
    path_mock.expect(:glob, [ file_path ], [ "sample.*" ])

    Rails.root.stub(:join, path_mock) do
      File.stub(:exist?, true) do
        File.stub(:binread, "fake image data") do
          Marcel::MimeType.stub(:for, "image/jpeg") do
            # Mock ActiveStorage attachment
            blob = OpenStruct.new(signed_id: "signed_id")
            @article.content_images.stub(:attach, [ blob ]) do
              @controller.stub(:rails_blob_url, "http://example.com/rails/blobs/signed_id/sample.jpg") do
                processed_content = @controller.send(:process_inline_images, content_with_image)

                assert_includes processed_content, "http://example.com/rails/blobs/signed_id/sample.jpg"
                assert_includes processed_content, "![alt text]"
              end
            end
          end
        end
      end
    end
    path_mock.verify
  end

  def test_process_inline_images_with_missing_file
    content_with_image = "![alt text](https://example.com/temp-file/sample.jpg)"
    get articles_url
    @controller = @controller.class.new

    path_mock = Minitest::Mock.new
    path_mock.expect(:glob, [ nil ], [ "sample.*" ])

    Rails.root.stub(:join, path_mock) do
      logger_output = StringIO.new
      Rails.logger.stub(:error, ->(msg) { logger_output.puts(msg) }) do
        processed_content = @controller.send(:process_inline_images, content_with_image)

        assert_equal content_with_image + "\r\n", processed_content
        assert_includes logger_output.string, "Temp file not found: sample.jpg"
      end
    end
    path_mock.verify
  end

  def test_process_inline_images_with_no_images
    content_without_image = "This is a test content without images."
    get articles_url
    @controller = @controller.class.new
    @controller.instance_variable_set(:@article, @article)

    processed_content = @controller.send(:process_inline_images, content_without_image)
    assert_equal content_without_image + "\r\n", processed_content
  end

  def test_process_inline_images_with_error
    content_with_image = "![alt text](https://example.com/temp-file/sample.jpg)"
    get articles_url
    @controller = @controller.class.new

    path_mock = Minitest::Mock.new
    path_mock.expect(:glob, [ Rails.root.join("tmp/uploads/sample.jpg") ], [ "sample.*" ])

    Rails.root.stub(:join, path_mock) do
      File.stub(:exist?, true) do
        File.stub(:binread, ->(_) { raise StandardError.new("Test error") }) do
          logger_output = StringIO.new
          Rails.logger.stub(:error, ->(msg) { logger_output.puts(msg) }) do
            processed_content = @controller.send(:process_inline_images, content_with_image)

            assert_equal content_with_image + "\r\n", processed_content
            assert_includes logger_output.string, "Error processing image: StandardError - Test error"
          end
        end
      end
    end
    path_mock.verify
  end
end
