require File.expand_path('../../test_helper', File.dirname(__FILE__))

class PageTextTagTest < ActiveSupport::TestCase
  
  def test_initialize_tag
    assert tag = ComfortableMexicanSofa::Tag::PageText.initialize_tag(
      cms_pages(:default), '{{ cms:page:content:text }}'
    )
    assert_equal 'content', tag.label
    assert tag = ComfortableMexicanSofa::Tag::PageText.initialize_tag(
      cms_pages(:default), '{{cms:page:content}}'
    )
    assert_equal 'content', tag.label
    assert tag = ComfortableMexicanSofa::Tag::PageText.initialize_tag(
      cms_pages(:default), '{{cms:page:content:text}}'
    )
    assert_equal 'content', tag.label
    assert tag = ComfortableMexicanSofa::Tag::PageText.initialize_tag(
      cms_pages(:default), '{{cms:page:dash-content}}'
    )
    assert_equal 'dash-content', tag.label
  end
  
  def test_initialize_tag_failure
    [
      '{{cms:page:content:not_text}}',
      '{{cms:not_page:content}}',
      '{not_a_tag}'
    ].each do |tag_signature|
      assert_nil ComfortableMexicanSofa::Tag::PageText.initialize_tag(
        cms_pages(:default), tag_signature
      )
    end
  end
  
  def test_content_and_render
    tag = ComfortableMexicanSofa::Tag::PageText.initialize_tag(
      cms_pages(:default), '{{cms:page:content}}'
    )
    assert tag.content.blank?
    tag.content = 'test_content'
    assert_equal 'test_content', tag.content
    assert_equal 'test_content', tag.render
  end
  
end