require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @page = pages(:about) # Assuming you have a fixture named 'about'
  end

  test "should get index" do
    get pages_url
    assert_response :success
    assert_not_nil assigns(:pages)
  end

  test "should get new" do
    get new_page_url
    assert_response :success
  end

  test "should create page" do
    assert_difference("Page.count") do
      post pages_url, params: { page: { title: "New Page", content: "New content" } }
    end

    assert_redirected_to page_url(Page.last)
  end

  test "should show page" do
    get page_url(@page)
    assert_response :success
  end

  test "should get edit" do
    get edit_page_url(@page)
    assert_response :success
  end

  test "should update page" do
    patch page_url(@page), params: { page: { title: "Updated Title", content: "Updated content" } }
    assert_redirected_to page_url(@page)
  end

  test "should destroy page" do
    assert_difference("Page.count", -1) do
      delete page_url(@page)
    end

    assert_redirected_to pages_url
  end

  test "should not create page with invalid params" do
    assert_no_difference('Page.count') do
      post pages_url, params: { page: { title: "", content: "" } }
    end

    assert_response :unprocessable_entity
    assert_template :new
  end

  test "should not update page with invalid params" do
    patch page_url(@page), params: { page: { title: "", content: "" } }
    
    assert_response :unprocessable_entity
    assert_template :edit
  end

  # Add JSON format tests for completeness
  test "should handle json format in create" do
    assert_difference('Page.count') do
      post pages_url(format: :json), params: { 
        page: { title: "JSON Page", content: "JSON content" } 
      }
    end
    assert_response :created
    assert_equal "application/json", @response.media_type
  end

  test "should handle json format in failed create" do
    post pages_url(format: :json), params: { 
      page: { title: "", content: "" } 
    }
    assert_response :unprocessable_entity
    assert_equal "application/json", @response.media_type
  end

  test "should handle json format in update" do
    patch page_url(@page, format: :json), params: { 
      page: { title: "Updated via JSON", content: "Updated content" } 
    }
    assert_response :ok
    assert_equal "application/json", @response.media_type
  end

  test "should handle json format in failed update" do
    patch page_url(@page, format: :json), params: { 
      page: { title: "", content: "" } 
    }
    assert_response :unprocessable_entity
    assert_equal "application/json", @response.media_type
  end
end
