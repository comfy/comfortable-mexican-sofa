require File.expand_path('../../test_helper', File.dirname(__FILE__))

class UploadImageTest < ActiveSupport::TestCase
  
  def test_initialize_tag
    assert tag = ComfortableMexicanSofa::Tag::UploadImage.initialize_tag(
      cms_pages(:default), '{{ cms:upload:label:image }}'
    )
    assert_equal 'label', tag.label
    assert tag = ComfortableMexicanSofa::Tag::UploadImage.initialize_tag(
      cms_pages(:default), '{{cms:upload:label:image}}'
    )
    assert_equal 'label', tag.label
    assert tag = ComfortableMexicanSofa::Tag::UploadImage.initialize_tag(
      cms_pages(:default), '{{cms:upload:dash-label:image}}'
    )
    assert_equal 'dash-label', tag.label
  end
  
  def test_initialize_tag_failure
    [
      '{{cms:upload}}',
      '{{cms:not_upload:image}}',
      '{not_a_tag}'
    ].each do |tag_signature|
      assert_nil ComfortableMexicanSofa::Tag::UploadImage.initialize_tag(
        cms_pages(:default), tag_signature
      )
    end
  end
  
  def test_content_and_render
    tag = ComfortableMexicanSofa::Tag::UploadImage.initialize_tag(
      cms_pages(:default), '{{cms:upload:sample.jpg:image}}'
    )
    assert_equal "<img src='#{Cms::Upload.find_by_file_file_name("sample.jpg").file.url}' alt='sample.jpg' />", tag.content
    assert_equal "<img src='#{Cms::Upload.find_by_file_file_name("sample.jpg").file.url}' alt='sample.jpg' />", tag.render

    tag = ComfortableMexicanSofa::Tag::UploadImage.initialize_tag(
      cms_pages(:default), '{{cms:upload:sample.jpg:image:a sample image}}'
    )
    assert_equal "<img src='#{Cms::Upload.find_by_file_file_name("sample.jpg").file.url}' alt='a sample image' />", tag.content
    assert_equal "<img src='#{Cms::Upload.find_by_file_file_name("sample.jpg").file.url}' alt='a sample image' />", tag.render
    
    tag = ComfortableMexicanSofa::Tag::UploadImage.initialize_tag(
      cms_pages(:default), "{{cms:upload:doesnot_exist:image}}"
    )
    assert_equal nil, tag.content
    assert_equal '', tag.render
  end
end