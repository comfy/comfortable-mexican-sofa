require 'test_helper'

class CmsAdmin::AssetsControllerTest < ActionController::TestCase
  
  def test_index
    get :index
    assert_response :success
  end
  
  def test_create
    assert_difference 'CmsAsset.count', 1 do
      xhr :post, :create, :file => fixture_file_upload('files/valid_image.jpg') 
      assert_response :success
    end
  end
  
  def test_create
    assert_difference 'CmsAsset.count', -1 do
      xhr :delete, :destroy, :id => cms_assets(:default)
      assert_response :success
    end
  end
  
end
