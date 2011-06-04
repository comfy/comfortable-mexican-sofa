require File.expand_path('../../test_helper', File.dirname(__FILE__))

class UploadTest < ActiveSupport::TestCase
  
  def test_initialize_tag
    assert tag = ComfortableMexicanSofa::Tag::Upload.initialize_tag(
      cms_pages(:default), '{{ cms:upload:sample.jpg:image:alt text }}'
    )
    assert_equal cms_uploads(:default), tag.upload
    assert_equal 'sample.jpg', tag.label
    assert_equal ['image', 'alt text'], tag.params
  end
  
  def test_initialize_tag_failure
    [
      '{{cms:upload}}',
      '{{cms:not_upload:label}}',
      '{not_a_tag}'
    ].each do |tag_signature|
      assert_nil ComfortableMexicanSofa::Tag::Upload.initialize_tag(
        cms_pages(:default), tag_signature
      )
    end
  end
  
  def test_render_for_invalid
    tag = ComfortableMexicanSofa::Tag::Upload.initialize_tag(
      cms_pages(:default), '{{cms:upload:invalid.jpg}}'
    )
    assert_nil tag.upload
    assert_equal '', tag.render
  end
  
  def test_render
    upload = cms_uploads(:default)
    assert tag = ComfortableMexicanSofa::Tag::Upload.initialize_tag(
      cms_pages(:default), '{{ cms:upload:sample.jpg }}'
    )
    assert_equal upload.file.url, tag.render
  end
  
  def test_render_for_link
    upload = cms_uploads(:default)
    assert tag = ComfortableMexicanSofa::Tag::Upload.initialize_tag(
      cms_pages(:default), '{{ cms:upload:sample.jpg:link }}'
    )
    assert_equal "<a href='#{upload.file.url}' target='_blank'>sample.jpg</a>", tag.render
    
    assert tag = ComfortableMexicanSofa::Tag::Upload.initialize_tag(
      cms_pages(:default), '{{ cms:upload:sample.jpg:link:link text }}'
    )
    assert_equal "<a href='#{upload.file.url}' target='_blank'>link text</a>", tag.render
  end
  
  def test_render_for_image
    upload = cms_uploads(:default)
    assert tag = ComfortableMexicanSofa::Tag::Upload.initialize_tag(
      cms_pages(:default), '{{ cms:upload:sample.jpg:image }}'
    )
    assert_equal "<img src='#{upload.file.url}' alt='sample.jpg' />", tag.render
    
    assert tag = ComfortableMexicanSofa::Tag::Upload.initialize_tag(
      cms_pages(:default), '{{ cms:upload:sample.jpg:image:alt text }}'
    )
    assert_equal "<img src='#{upload.file.url}' alt='alt text' />", tag.render
  end
end