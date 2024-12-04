require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  test "markdown returns empty string for blank input" do
    assert_equal "", markdown(nil)
    assert_equal "", markdown("")
    assert_equal "", markdown("   ")
  end

  test "markdown renders basic text" do
    input = "Hello, world!"
    result = markdown(input)
    assert_match /Hello, world!/, result
  end

  test "markdown renders code blocks with language" do
    input = <<~MARKDOWN
      ```ruby
      def hello
        puts "world"
      end
      ```
    MARKDOWN

    result = markdown(input)

    assert_includes result, "[RUBY]"
    assert_includes result, 'data-controller="code-copy"'
    assert_includes result, "line-numbers"

    expected_code = Base64.strict_encode64("def hello\n  puts \"world\"\nend\n")
    assert_includes result, "data-code=\"#{expected_code}\""
  end

  test "markdown renders code blocks without language" do
    input = <<~MARKDOWN
      ```
      plain text
      ```
    MARKDOWN

    result = markdown(input)

    assert_match /\[TEXT\]/, result
    assert_match /plain text/, result
  end

  test "markdown renders images with title" do
    input = "![Alt text](image.jpg \"Image title\")"
    result = markdown(input)

    assert_match /<figure/, result
    assert_match /src='image\.jpg'/, result
    assert_match /alt='Alt text'/, result
    assert_match /<figcaption/, result
    assert_match /Image title/, result
  end

  test "markdown renders images without title" do
    input = "![Alt text](image.jpg)"
    result = markdown(input)

    assert_no_match /<figure/, result
    assert_match /src='image\.jpg'/, result
    assert_match /alt='Alt text'/, result
    assert_no_match /<figcaption/, result
  end

  test "markdown renders tables" do
    input = <<~MARKDOWN
      | Header 1 | Header 2 |
      |----------|----------|
      | Cell 1   | Cell 2   |
    MARKDOWN

    result = markdown(input)
    assert_match /<table/, result
    assert_match /<th/, result
    assert_match /<td/, result
  end

  test "markdown renders autolinks" do
    input = "https://example.com"
    result = markdown(input)
    assert_match /<a href/, result
    assert_match /https:\/\/example\.com/, result
  end

  test "markdown renders strikethrough" do
    input = "~~strikethrough~~"
    result = markdown(input)
    assert_match /<del>strikethrough<\/del>/, result
  end

  test "markdown renders superscript" do
    input = "2^nd"
    result = markdown(input)
    assert_match /<sup>nd<\/sup>/, result
  end
end
