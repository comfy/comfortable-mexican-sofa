require File.expand_path('../../test_helper', File.dirname(__FILE__))

class UploadTextTest < ActiveSupport::TestCase
  
  def test_initialize_tag
    assert tag = ComfortableMexicanSofa::Tag::UploadText.initialize_tag(
      cms_pages(:default), '{{ cms:upload:label }}'
    )
    assert_equal 'label', tag.label
    assert tag = ComfortableMexicanSofa::Tag::UploadText.initialize_tag(
      cms_pages(:default), '{{cms:upload:label}}'
    )
    assert_equal 'label', tag.label
    assert tag = ComfortableMexicanSofa::Tag::UploadText.initialize_tag(
      cms_pages(:default), '{{cms:upload:dash-label}}'
    )
    assert_equal 'dash-label', tag.label
  end
  
  def test_initialize_tag_failure
    [
      '{{cms:upload}}',
      '{{cms:not_upload:text}}',
      '{not_a_tag}'
    ].each do |tag_signature|
      assert_nil ComfortableMexicanSofa::Tag::UploadText.initialize_tag(
        cms_pages(:default), tag_signature
      )
    end
  end
  
  def test_content_and_render
    tag = ComfortableMexicanSofa::Tag::UploadText.initialize_tag(
      cms_pages(:default), '{{cms:upload:sample.jpg}}'
    )
    assert_equal Cms::Upload.find_by_file_file_name("sample.jpg").file.url, tag.content
    assert_equal Cms::Upload.find_by_file_file_name("sample.jpg").file.url, tag.render
    
    tag = ComfortableMexicanSofa::Tag::UploadText.initialize_tag(
      cms_pages(:default), "{{cms:upload:doesnot_exist}}"
    )
    assert_equal nil, tag.content
    assert_equal '', tag.render
  end
end