require "test_helper"

class ArticleTest < ActiveSupport::TestCase
  def setup
    @user = users(:morty)
    @article = Article.new(
      title: "Test Article",
      content: "Test content",
      status: "draft",
      user: @user
    )
  end

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

  test "abstract_word_limit validates word count" do
    # Test with blank abstract (should pass)
    @article.abstract = ""
    assert @article.valid?

    # Test with 30 words (should pass)
    @article.abstract = "word " * 30
    assert @article.valid?

    # Test with 31 words (should fail)
    @article.abstract = "word " * 31
    assert_not @article.valid?
    assert_includes @article.errors[:abstract], "must be 30 words or less (currently: 31 words)"
  end

  test "purge_cover_image is called on destroy" do
    @article.save!  # Save the article first
    @article.cover_image.attach(
      io: File.open(Rails.root.join("test/fixtures/files/test_image.jpg")),
      filename: "test_image.jpg"
    )

    assert @article.cover_image.attached?
    blob = @article.cover_image.blob  # Store the blob reference before destroy
    @article.destroy
    assert_enqueued_with(job: ActiveStorage::PurgeJob, args: [ blob ])
  end

  test "purge_content_images is called on destroy" do
    @article.save!  # Save the article first
    @article.content_images.attach(
      io: File.open(Rails.root.join("test/fixtures/files/test_image.jpg")),
      filename: "test_image.jpg"
    )

    assert @article.content_images.attached?
    blob = @article.content_images.first.blob  # Store the blob reference before destroy
    @article.destroy
    assert_enqueued_with(job: ActiveStorage::PurgeJob, args: [ blob ])
  end

  test "purge_content_images handles article without content images" do
    @article.save!
    assert_not @article.content_images.attached?
    
    # No job should be enqueued when there are no images
    assert_no_enqueued_jobs(only: ActiveStorage::PurgeJob) do
      @article.destroy
    end
  end
end
