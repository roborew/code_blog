require "simplecov"
SimpleCov.start "rails" do
  enable_coverage :branch
  track_files "app/**/*.rb"

  add_filter "/test/"
  add_filter "/config/"
  add_filter "/vendor/"

  add_group "Controllers", "app/controllers"
  add_group "Models", "app/models"
  add_group "Helpers", "app/helpers"
  add_group "Libraries", "lib"
end

ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Comment out or remove the parallelize call
    # parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
    include Devise::Test::IntegrationHelpers
    include ActionDispatch::TestProcess
    include ActiveJob::TestHelper

    # Add this helper method for all tests to use
    def fixture_file_upload(filename = "test_image.jpg", content_type = "image/jpeg")
      path = Rails.root.join("test", "fixtures", "files", filename)
      Rack::Test::UploadedFile.new(path, content_type)
    end
  end
end
