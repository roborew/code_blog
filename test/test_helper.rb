require "simplecov"
SimpleCov.start
ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
    include Devise::Test::IntegrationHelpers
    include ActionDispatch::TestProcess

    # Add this helper method for all tests to use
    def fixture_file_upload(filename = "test_image.jpg", content_type = "image/jpeg")
      path = Rails.root.join("test", "fixtures", "files", filename)
      Rack::Test::UploadedFile.new(path, content_type)
    end
  end
end
