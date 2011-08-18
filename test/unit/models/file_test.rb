require File.expand_path('../../test_helper', File.dirname(__FILE__))

class CmsFileTest < ActiveSupport::TestCase
  
  def test_fixtures_validity
    Cms::File.all.each do |file|
      assert file.valid?, file.errors.full_messages.to_s
    end
  end
  
  def test_validations
    assert_no_difference 'Cms::File.count' do
      file = Cms::File.create
      assert file.errors.present?
      assert_has_errors_on file, [:file_file_name]
    end
  end
  
  def test_create
    assert_difference 'Cms::File.count' do
      file = cms_sites(:default).files.create(
        :file => fixture_file_upload('files/valid_image.jpg')
      )
      assert_equal 'Valid Image', file.label
    end
  end
  
  def test_create_failure
    assert_no_difference 'Cms::File.count' do
      cms_sites(:default).files.create(:file => '')
    end
  end
end
