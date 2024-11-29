require "application_system_test_case"

class ArticlesTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:morty)
    sign_in @user
    @article = articles(:one)
  end

  test "visiting the index" do
    sign_out @user
    visit articles_url
    assert_selector "h1", text: "Articles"
  end

  test "should create article" do
    visit articles_url
    click_on "New article"

    # Wait for the hidden field to be present in the DOM, including hidden elements
    assert_selector '[data-milkdown-target="content"]', visible: :all
    # Set the content using JavaScript since the field is hidden
    page.execute_script("document.querySelector('[data-milkdown-target=\"content\"]').value = '#{@article.content}'")

   # Set publication date to current time with proper format (DD/MM/YYYY)
   current_time = Time.current
   fill_in "article[publication_date]", with: current_time.strftime("%d/%m/%Y")
    fill_in "Title", with: @article.title
    click_on "Create Article"

    assert_text "Article was successfully created"
    click_on "Back"
  end

  test "should update Article" do
    visit article_url(@article)
    click_on "Edit this article", match: :first

    # Wait for the hidden field to be present in the DOM, including hidden elements
    assert_selector '[data-milkdown-target="content"]', visible: :all
    # Set the content using JavaScript since the field is hidden
    page.execute_script("document.querySelector('[data-milkdown-target=\"content\"]').value = '#{@article.content}'")

    fill_in "Publication date", with: @article.publication_date.to_s
    fill_in "Title", with: @article.title
    click_on "Update Article"

    assert_text "Article was successfully updated"
    click_on "Back"
  end

  test "should destroy Article" do
    visit article_url(@article)
    click_on "Destroy this article", match: :first

    assert_text "Article was successfully destroyed"
  end

  test "should create article with status" do
    visit articles_url
    click_on "New article"

    # Fill in the required fields
    fill_in "article[title]", with: "Test Article"

    # Wait for the hidden field to be present in the DOM
    assert_selector '[data-milkdown-target="content"]', visible: :all
    # Set the content using JavaScript
    page.execute_script("document.querySelector('[data-milkdown-target=\"content\"]').value = 'Test Content'")

    # Handle categories and tags
    page.execute_script("document.getElementById('categories-input').value = '[]'")
    page.execute_script("document.getElementById('tags-input').value = '[]'")

    # Set publication date to current time with proper format (DD/MM/YYYY)
    current_time = Time.current
    fill_in "article[publication_date]", with: current_time.strftime("%d/%m/%Y")

    # Set status
    select "Draft", from: "article[status]"

    # Debug form state
    puts "Form values before submission:"
    puts "Title: #{page.find('#article_title').value}"
    puts "Content: #{page.find('[data-milkdown-target="content"]', visible: :all).value}"
    puts "Publication Date: #{page.find('#article_publication_date').value}"
    puts "Status: #{page.find('#article_status').value}"

    # Submit form and wait for Turbo
    click_button "Create Article"
    sleep(1)

    # Debug response
    puts "Current URL: #{page.current_url}"
    puts "Page content after submission:"
    # puts page.html

    # Check for any error messages
    if page.has_css?(".field_with_errors")
      puts "Validation errors found:"
      page.all(".field_with_errors").each do |error|
        puts error.text
      end
    end

    assert_text "Article was successfully created"

    # Verify the article was created
    article = Article.last
    assert_equal "draft", article.status
    assert_equal "Test Article", article.title
  end

  test "should update Article status" do
    visit article_url(@article)
    click_on "Edit this article", match: :first

    # Wait for the hidden field to be present in the DOM, including hidden elements
    assert_selector '[data-milkdown-target="content"]', visible: :all
    # Set the content using JavaScript since the field is hidden
    page.execute_script("document.querySelector('[data-milkdown-target=\"content\"]').value = '#{@article.content}'")

    # Handle categories and tags inputs (assuming they expect JSON arrays)
    page.execute_script("document.getElementById('categories-input').value = '[\"category1\", \"category2\"]'")
    page.execute_script("document.getElementById('tags-input').value = '[\"tag1\", \"tag2\"]'")

    select "Archived", from: "Status"
    click_on "Update Article"

    assert_text "Article was successfully updated"
    assert_equal "archived", @article.reload.status
    click_on "Back"
  end
end
