require File.dirname(__FILE__) + '/../test_helper'

class CmsAssetTest < ActiveSupport::TestCase
  
  def test_validations
    asset = CmsAsset.create
    assert asset.errors.present?
    assert_has_errors_on asset, [:file_file_name]
  end
  
  def test_create
    assert_difference 'CmsAsset.count', 2 do
      asset = CmsAsset.create(:file => fixture_file_upload('files/valid_image.jpg', 'image/jpeg'))
      assert asset.image?
      asset = CmsAsset.create(:uploaded_file => fixture_file_upload('files/valid_image.jpg'))
      assert asset.image?
    end
  end
  
end
