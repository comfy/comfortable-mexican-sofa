require File.expand_path('../../test_helper', File.dirname(__FILE__))

class UploadLinkTest < ActiveSupport::TestCase
  
  def test_initialize_tag
    assert tag = ComfortableMexicanSofa::Tag::UploadLink.initialize_tag(
      cms_pages(:default), '{{ cms:upload:label:link }}'
    )
    assert_equal 'label', tag.label
    assert tag = ComfortableMexicanSofa::Tag::UploadLink.initialize_tag(
      cms_pages(:default), '{{cms:upload:label:link}}'
    )
    assert_equal 'label', tag.label
    assert tag = ComfortableMexicanSofa::Tag::UploadLink.initialize_tag(
      cms_pages(:default), '{{cms:upload:dash-label:link}}'
    )
    assert_equal 'dash-label', tag.label
  end
  
  def test_initialize_tag_failure
    [
      '{{cms:upload}}',
      '{{cms:not_upload:link}}',
      '{not_a_tag}'
    ].each do |tag_signature|
      assert_nil ComfortableMexicanSofa::Tag::UploadLink.initialize_tag(
        cms_pages(:default), tag_signature
      )
    end
  end
  
  def test_content_and_render
    tag = ComfortableMexicanSofa::Tag::UploadLink.initialize_tag(
      cms_pages(:default), '{{cms:upload:sample.jpg:link}}'
    )
    assert_equal "<a href='#{Cms::Upload.find_by_file_file_name("sample.jpg").file.url}'>sample.jpg</a>", tag.content
    assert_equal "<a href='#{Cms::Upload.find_by_file_file_name("sample.jpg").file.url}'>sample.jpg</a>", tag.render

    tag = ComfortableMexicanSofa::Tag::UploadLink.initialize_tag(
      cms_pages(:default), '{{cms:upload:sample.jpg:link:a sample image}}'
    )
    assert_equal "<a href='#{Cms::Upload.find_by_file_file_name("sample.jpg").file.url}'>a sample image</a>", tag.content
    assert_equal "<a href='#{Cms::Upload.find_by_file_file_name("sample.jpg").file.url}'>a sample image</a>", tag.render
    
    tag = ComfortableMexicanSofa::Tag::UploadLink.initialize_tag(
      cms_pages(:default), "{{cms:upload:doesnot_exist:link}}"
    )
    assert_equal nil, tag.content
    assert_equal '', tag.render
  end
end