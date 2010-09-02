require File.dirname(__FILE__) + '/../test_helper'

class CmsAssetTest < ActiveSupport::TestCase
  
  def test_validations
    assert_no_difference 'CmsAsset.count' do
      asset = CmsAsset.create
      assert asset.errors.present?
      assert_has_errors_on asset, [:file_file_name]
    end
  end
  
  def test_create
    assert_difference 'CmsAsset.count', 2 do
      asset = CmsAsset.create(:file => fixture_file_upload('files/valid_image.jpg', 'image/jpeg'))
      assert asset.image?
      asset = CmsAsset.create(:uploaded_file => fixture_file_upload('files/valid_image.jpg'))
      assert asset.image?
    end
  end
  
  def test_create_fails_on_invalid_file
    assert_no_difference 'CmsAsset.count' do
      asset = CmsAsset.create(:file => fixture_file_upload('files/invalid_file.gif', 'image/gif'))
      assert asset.errors.present?
      assert_has_errors_on asset, :file
    end
  end
  
end
