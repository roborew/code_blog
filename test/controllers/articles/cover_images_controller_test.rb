require "test_helper"

class Articles::CoverImagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:morty) # Assuming you have a fixture for users
    @article = articles(:one) # Assuming you have a fixture for articles
    sign_in @user

    # Attach a cover image to the article
    @article.cover_image.attach(
      io: File.open(Rails.root.join("test/fixtures/files/test_image.jpg")),
      filename: "test_image.jpg"
    )
  end

  test "should purge cover image and redirect to edit article path" do
    assert @article.cover_image.attached?
    blob = @article.cover_image.blob

    assert_enqueued_with(job: ActiveStorage::PurgeJob, args: [ blob ]) do
      delete article_cover_image_path(@article)
    end

    perform_enqueued_jobs
    @article.reload
    assert_not @article.cover_image.attached?
    assert_redirected_to edit_article_path(@article)
  end

  test "should purge cover image and remove via turbo stream" do
    assert @article.cover_image.attached?
    blob = @article.cover_image.blob

    assert_enqueued_with(job: ActiveStorage::PurgeJob, args: [ blob ]) do
      delete article_cover_image_path(@article), headers: { "Accept" => "text/vnd.turbo-stream.html" }
    end

    perform_enqueued_jobs
    @article.reload
    assert_not @article.cover_image.attached?
    assert_response :success
    assert_match /turbo-stream/, @response.body
  end

  private

  def article_cover_image_path(article)
    "/articles/#{article.id}/cover_image"
  end
end
