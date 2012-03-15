require File.expand_path('../../test_helper', File.dirname(__FILE__))

class FieldRichTextTagTest < ActiveSupport::TestCase
  
  def test_initialize_tag
    assert tag = ComfortableMexicanSofa::Tag::FieldRichText.initialize_tag(
      cms_pages(:default), '{{ cms:field:content:rich_text }}'
    )
    assert_equal 'content', tag.identifier
    assert tag = ComfortableMexicanSofa::Tag::FieldRichText.initialize_tag(
      cms_pages(:default), '{{cms:field:content:rich_text}}'
    )
    assert_equal 'content', tag.identifier
    assert tag = ComfortableMexicanSofa::Tag::FieldRichText.initialize_tag(
      cms_pages(:default), '{{cms:field:dash-content:rich_text}}'
    )
    assert_equal 'dash-content', tag.identifier
  end
  
  def test_initialize_tag_failure
    [
      '{{cms:field:content:not_rich_text}}',
      '{{cms:field:content}}',
      '{{cms:not_page:content}}',
      '{not_a_tag}'
    ].each do |tag_signature|
      assert_nil ComfortableMexicanSofa::Tag::FieldRichText.initialize_tag(
        cms_pages(:default), tag_signature
      )
    end
  end
  
  def test_content_and_render
    tag = ComfortableMexicanSofa::Tag::FieldRichText.initialize_tag(
      cms_pages(:default), '{{cms:field:content:rich_text}}'
    )
    assert tag.block.content.blank?
    tag.block.content = 'test_content'
    assert_equal 'test_content', tag.content
    assert_equal '', tag.render
  end
  
end