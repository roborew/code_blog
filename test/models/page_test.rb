require "test_helper"

class PageTest < ActiveSupport::TestCase
  test "should not save page without title" do
    page = Page.new(content: "Some content")
    assert_not page.save, "Saved the page without a title"
  end

  test "should not save page without content" do
    page = Page.new(title: "About Us")
    assert_not page.save, "Saved the page without content"
  end

  test "should save valid page" do
    page = Page.new(title: "About Us", content: "Some content")
    assert page.save, "Could not save valid page"
  end

  test "should generate slug from title" do
    page = Page.create(title: "About Us Page", content: "Some content")
    assert_equal "about-us-page", page.slug
  end

  test "should find page by slug" do
    page = Page.create(title: "Contact Us", content: "Some content")
    assert_equal page, Page.friendly.find("contact-us")
  end
end 