require_relative '../../test_helper'

class FileTagTest < ActiveSupport::TestCase
  
  def test_initialize_tag
    assert tag = ComfortableMexicanSofa::Tag::File.initialize_tag(
      cms_pages(:default), '{{ cms:file:sample.jpg:image:alt text }}'
    )
    assert_equal cms_files(:default), tag.file
    assert_equal 'sample.jpg', tag.identifier
    assert_equal ['image', 'alt text'], tag.params
  end
  
  def test_initialize_tag_failure
    [
      '{{cms:file}}',
      '{{cms:not_file:label}}',
      '{not_a_tag}'
    ].each do |tag_signature|
      assert_nil ComfortableMexicanSofa::Tag::File.initialize_tag(
        cms_pages(:default), tag_signature
      )
    end
  end
  
  def test_render_for_invalid
    tag = ComfortableMexicanSofa::Tag::File.initialize_tag(
      cms_pages(:default), '{{cms:file:invalid.jpg}}'
    )
    assert_nil tag.file
    assert_equal '', tag.render
  end
  
  def test_render
    file = cms_files(:default)
    assert tag = ComfortableMexicanSofa::Tag::File.initialize_tag(
      cms_pages(:default), '{{ cms:file:sample.jpg }}'
    )
    assert_equal file.file.url, tag.render
  end
  
  def test_render_for_link
    file = cms_files(:default)
    assert tag = ComfortableMexicanSofa::Tag::File.initialize_tag(
      cms_pages(:default), '{{ cms:file:sample.jpg:link }}'
    )
    assert_equal "<a href='#{file.file.url}' target='_blank'>sample.jpg</a>", tag.render
    
    assert tag = ComfortableMexicanSofa::Tag::File.initialize_tag(
      cms_pages(:default), '{{ cms:file:sample.jpg:link:link text }}'
    )
    assert_equal "<a href='#{file.file.url}' target='_blank'>link text</a>", tag.render
  end
  
  def test_render_for_image
    file = cms_files(:default)
    assert tag = ComfortableMexicanSofa::Tag::File.initialize_tag(
      cms_pages(:default), '{{ cms:file:sample.jpg:image }}'
    )
    assert_equal "<img src='#{file.file.url}' alt='sample.jpg' />", tag.render
    
    assert tag = ComfortableMexicanSofa::Tag::File.initialize_tag(
      cms_pages(:default), '{{ cms:file:sample.jpg:image:alt text }}'
    )
    assert_equal "<img src='#{file.file.url}' alt='alt text' />", tag.render
  end
end