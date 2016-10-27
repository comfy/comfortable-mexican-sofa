require_relative '../test_helper'

class CmsFileTest < ActiveSupport::TestCase
  
  def test_fixtures_validity
    # stubbing out Paperclip 4.0 mimetype validation
    if defined? Paperclip::Validators::MediaTypeSpoofDetectionValidator
      Paperclip::Validators::MediaTypeSpoofDetectionValidator.any_instance.stubs(:validate_each).returns(true)
    end
    
    Comfy::Cms::File.all.each do |file|
      assert file.valid?, file.errors.full_messages.to_s
    end
  end
  
  def test_validations
    file = Comfy::Cms::File.new
    assert file.invalid?
    assert_has_errors_on file, :site_id, :file
  end
  
  def test_validations_uniqueness
    comfy_cms_files(:default).update_column(:file_file_name, 'image.jpg')
    file = comfy_cms_sites(:default).files.new(
      :file => fixture_file_upload('files/image.jpg', 'image/jpeg')
    )
    assert file.invalid?
    assert_has_errors_on file, :file_file_name
    
    file = comfy_cms_sites(:default).files.new(
      :block_id => comfy_cms_blocks(:default_field_text).id,
      :file     => fixture_file_upload('files/image.jpg', 'image/jpeg')
    )
    assert file.valid?
  end
  
  def test_create
    assert_difference 'Comfy::Cms::File.count' do
      upload = fixture_file_upload('files/image.jpg', 'image/jpeg')
      
      file = comfy_cms_sites(:default).files.create(
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
    assert_difference 'Comfy::Cms::File.count' do
      upload = fixture_file_upload('files/image.jpg', 'image/jpeg')
      
      file = comfy_cms_sites(:default).files.create!(
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
    assert_difference 'Comfy::Cms::File.count' do
      file = comfy_cms_sites(:default).files.create!(
        :file => fixture_file_upload('files/data.zip', 'application/zip')
      )
      assert_equal 'Data', file.label
      assert_equal 'data.zip', file.file_file_name
      assert_equal 'application/zip', file.file_content_type
    end
  end
  
  def test_create_failure
    assert_no_difference 'Comfy::Cms::File.count' do
      comfy_cms_sites(:default).files.create
    end
  end
  
  def test_image_mimetypes
    assert_equal %w(image/gif image/jpeg image/pjpeg image/png image/tiff),
      Comfy::Cms::File::IMAGE_MIMETYPES
  end
  
  def test_scope_images
    file = comfy_cms_files(:default)
    assert_equal 'image/jpeg', file.file_content_type
    assert_equal 1, Comfy::Cms::File.images.count
    assert_equal 0, Comfy::Cms::File.not_images.count
    
    file.update_columns(:file_content_type => 'application/pdf')
    assert_equal 0, Comfy::Cms::File.images.count
    assert_equal 1, Comfy::Cms::File.not_images.count
  end
  
  def test_scope_not_page_file
    file = comfy_cms_files(:default)
    assert file.block.blank?
    assert_equal 1, Comfy::Cms::File.not_page_file.count
    
    file.update_attribute(:block, comfy_cms_blocks(:default_field_text))
    assert_equal 0, Comfy::Cms::File.not_page_file.count
  end
  
  def test_image?
    file = comfy_cms_files(:default)
    assert_equal 'image/jpeg', file.file_content_type
    assert file.is_image?
  end
  
end
