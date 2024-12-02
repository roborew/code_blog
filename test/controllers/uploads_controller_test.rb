require "test_helper"

class UploadsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:morty) # Assuming you have a fixture for users
    @file = fixture_file_upload("test_image.jpg", "image/jpeg")
  end

  test "should return unauthorized if not logged in for upload_image" do
    post uploads_upload_image_url
    assert_response :unauthorized
    assert_equal "Unauthorized", JSON.parse(response.body)["error"]
  end

  test "should upload image and return url if logged in" do
    sign_in @user
    post uploads_upload_image_url, params: { file: @file }
    assert_response :success
    assert JSON.parse(response.body).key?("url")
  end

  test "should return error if no file provided" do
    sign_in @user
    post uploads_upload_image_url
    assert_response :unprocessable_entity
    assert_equal "No file provided", JSON.parse(response.body)["error"]
  end

  test "should return unauthorized if not logged in for serve_temp_file" do
    get serve_temp_file_url(filename: "test_image.jpg")
    assert_response :unauthorized
    assert_equal "Unauthorized", JSON.parse(response.body)["error"]
  end

  test "should serve file if logged in and file exists" do
    sign_in @user
    post uploads_upload_image_url, params: { file: @file }
    filename = JSON.parse(response.body)["url"].split("/").last

    get serve_temp_file_url(filename: filename)
    assert_response :success
  end

  test "should return not found if file does not exist" do
    sign_in @user
    get serve_temp_file_url(filename: "non_existent.jpg")
    assert_response :not_found
    assert_equal "File not found", JSON.parse(response.body)["error"]
  end
end
