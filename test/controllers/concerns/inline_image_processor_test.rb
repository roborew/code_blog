require "test_helper"
require "ostruct"
require "minitest/mock"

class DummyController < ActionController::Base
  include InlineImageProcessor
end

class InlineImageProcessorTest < ActionDispatch::IntegrationTest
  setup do
    @controller = DummyController.new
    @article = articles(:one)
    @controller.instance_variable_set(:@article, @article)
  end

  test "process_inline_images with existing file" do
    content_with_image = "![alt text](https://example.com/temp-file/sample.jpg)"
    file_path = Rails.root.join("tmp/uploads/sample.jpg")

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
                processed_content = @controller.process_inline_images(content_with_image)

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

  test "process_inline_images with missing file" do
    content_with_image = "![alt text](https://example.com/temp-file/sample.jpg)"

    path_mock = Minitest::Mock.new
    path_mock.expect(:glob, [ nil ], [ "sample.*" ])

    Rails.root.stub(:join, path_mock) do
      logger_output = StringIO.new
      Rails.logger.stub(:error, ->(msg) { logger_output.puts(msg) }) do
        processed_content = @controller.process_inline_images(content_with_image)

        assert_equal content_with_image, processed_content
        assert_includes logger_output.string, "Temp file not found: sample.jpg"
      end
    end
    path_mock.verify
  end

  test "process_inline_images with no images" do
    content_without_image = "This is a test content without images."
    processed_content = @controller.process_inline_images(content_without_image)
    assert_equal content_without_image, processed_content
  end

  test "process_inline_images with error" do
    content_with_image = "![alt text](https://example.com/temp-file/sample.jpg)"

    path_mock = Minitest::Mock.new
    path_mock.expect(:glob, [ Rails.root.join("tmp/uploads/sample.jpg") ], [ "sample.*" ])

    Rails.root.stub(:join, path_mock) do
      File.stub(:exist?, true) do
        File.stub(:binread, ->(_) { raise StandardError.new("Test error") }) do
          logger_output = StringIO.new
          Rails.logger.stub(:error, ->(msg) { logger_output.puts(msg) }) do
            processed_content = @controller.process_inline_images(content_with_image)

            assert_equal content_with_image, processed_content
            assert_includes logger_output.string, "Error processing image: StandardError - Test error"
          end
        end
      end
    end
    path_mock.verify
  end
end
