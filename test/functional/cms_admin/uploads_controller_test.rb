require File.expand_path('../../test_helper', File.dirname(__FILE__))

class CmsAdmin::UploadsControllerTest < ActionController::TestCase
  
  def test_create
    assert_difference 'Cms::Upload.count', 1 do
      xhr :post, :create, :site_id => cms_sites(:default), :file => fixture_file_upload('files/valid_image.jpg')
      assert_response :success
    end
  end
  
  def test_create_failure
    assert_no_difference 'Cms::Upload.count' do
      xhr :post, :create, :site_id => cms_sites(:default), :file => nil
      assert_response :bad_request
    end
  end
  
  def test_destroy
    assert_difference 'Cms::Upload.count', -1 do
      xhr :delete, :destroy, :site_id => cms_sites(:default), :id => cms_uploads(:default)
      assert_response :success
    end
  end
  
end
