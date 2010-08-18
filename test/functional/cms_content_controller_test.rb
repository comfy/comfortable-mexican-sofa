require 'test_helper'

class CmsContentControllerTest < ActionController::TestCase
  test "GET show" do
    get :show, :path => 'some-page'
    assert_response :success
  end
end
