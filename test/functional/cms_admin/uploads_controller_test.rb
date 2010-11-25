require 'test_helper'

class CmsAdmin::UploadsControllerTest < ActionController::TestCase
  
  def test_create
    assert_difference 'CmsUpload.count', 1 do
      xhr :post, :create, :file => fixture_file_upload('files/valid_image.jpg')
      assert_response :success
    end
  end
  
  def test_create_fails
    assert_no_difference 'CmsUpload.count' do
      xhr :post, :create, :file => nil
      assert_response :bad_request
    end
  end
  
  def test_destroy
    assert_difference 'CmsUpload.count', -1 do
      xhr :delete, :destroy, :id => cms_uploads(:default)
      assert_response :success
    end
  end
  
end
