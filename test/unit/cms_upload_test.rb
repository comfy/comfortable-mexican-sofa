require File.dirname(__FILE__) + '/../test_helper'

class CmsUploadTest < ActiveSupport::TestCase
  
  def test_validations
    assert_no_difference 'CmsUpload.count' do
      upload = CmsUpload.create
      assert upload.errors.present?
      assert_has_errors_on upload, [:file_file_name]
    end
  end
  
  def test_create
    assert_difference 'CmsUpload.count' do
      upload = cms_sites(:default).cms_uploads.create(
        :uploaded_file => fixture_file_upload('files/valid_image.jpg')
      )
      assert upload.image?
    end
  end
  
  def test_create_fails_on_invalid_file
    assert_no_difference 'CmsUpload.count' do
      upload = cms_sites(:default).cms_uploads.create(
        :file => fixture_file_upload('files/invalid_file.gif', 'image/gif')
      )
      assert upload.errors.present?
      assert_has_errors_on upload, :file
    end
  end
end
