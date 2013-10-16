require_relative '../test_helper'

class CmsFileTest < ActiveSupport::TestCase
  
  def test_fixtures_validity
    Cms::File.all.each do |file|
      assert file.valid?, file.errors.full_messages.to_s
    end
  end
  
  def test_validations
    file = Cms::File.new
    assert file.invalid?
    assert_has_errors_on file, :site_id, :file
    
    cms_files(:default).update_column(:file_file_name, 'image.jpg')
    file = cms_sites(:default).files.new(
      :file => fixture_file_upload('files/image.jpg', 'image/jpeg')
    )
    assert file.invalid?
    assert_has_errors_on file, :file_file_name
  end
  
  def test_create
    assert_difference 'Cms::File.count' do
      upload = fixture_file_upload('files/image.jpg', 'image/jpeg')
      
      file = cms_sites(:default).files.create(
        :file => upload
      )
      assert_equal 'Image', file.label
      assert_equal 'image.jpg', file.file_file_name
      assert_equal 'image/jpeg', file.file_content_type
      assert_equal upload.size, file.file_file_size
      assert_equal 1, file.position
    end
  end
  
  def test_create_with_dimensions
    assert_difference 'Cms::File.count' do
      upload = fixture_file_upload('files/image.jpg', 'image/jpeg')
      
      file = cms_sites(:default).files.create!(
        :dimensions => '10x10#',
        :file       => upload
      )
      assert_equal 'Image', file.label
      assert_equal 'image.jpg', file.file_file_name
      assert_equal 'image/jpeg', file.file_content_type
      # assert file.file_file_size < upload.size
      assert_equal 1, file.position
    end
  end
  
  def test_create_with_non_image
    assert_difference 'Cms::File.count' do
      file = cms_sites(:default).files.create!(
        :file => fixture_file_upload('files/data.zip', 'application/zip')
      )
      assert_equal 'Data', file.label
      assert_equal 'data.zip', file.file_file_name
      assert_equal 'application/zip', file.file_content_type
    end
  end
  
  def test_create_failure
    assert_no_difference 'Cms::File.count' do
      cms_sites(:default).files.create
    end
  end
  
  def test_image_mimetypes
    assert_equal %w(image/gif image/jpeg image/pjpeg image/png image/tiff),
      Cms::File::IMAGE_MIMETYPES
  end
  
  def test_images_scope
    file = cms_files(:default)
    assert_equal 'image/jpeg', file.file_content_type
    assert_equal 1, Cms::File.images.count
    assert_equal 0, Cms::File.not_images.count
    
    file.update_columns(:file_content_type => 'application/pdf')
    assert_equal 0, Cms::File.images.count
    assert_equal 1, Cms::File.not_images.count
  end
  
  def test_image?
    file = cms_files(:default)
    assert_equal 'image/jpeg', file.file_content_type
    assert file.is_image?
  end
  
end
