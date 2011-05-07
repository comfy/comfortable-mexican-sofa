require File.expand_path('../../test_helper', File.dirname(__FILE__))

class CmsUploadTest < ActiveSupport::TestCase
  
  def test_fixtures_validity
    Cms::Upload.all.each do |upload|
      assert upload.valid?, upload.errors.full_messages.to_s
    end
  end
  
  def test_validations
    assert_no_difference 'Cms::Upload.count' do
      upload = Cms::Upload.create
      assert upload.errors.present?
      assert_has_errors_on upload, [:file_file_name]
    end
  end
  
  def test_create
    assert_difference 'Cms::Upload.count' do
      cms_sites(:default).uploads.create(
        :file => fixture_file_upload('files/valid_image.jpg')
      )
    end
  end
  
  def test_create_failure
    assert_no_difference 'Cms::Upload.count' do
      cms_sites(:default).uploads.create(:file => '')
    end
  end
end
