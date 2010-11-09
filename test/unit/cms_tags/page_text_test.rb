require File.expand_path('../../test_helper', File.dirname(__FILE__))

class PageTextTest < ActiveSupport::TestCase
  
  def test_initialize_tag
    [
      '{{ cms:page:content:text }}',
      '{{cms:page:content}}',
      '{{cms:page:content:text}}'
    ].each do |tag_signature|
      assert tag = CmsTag::PageText.initialize_tag(cms_pages(:default), tag_signature)
      assert_equal 'content', tag.label
    end
  end
  
  def test_initialize_tag_failure
    [
      '{{cms:page:content:not_text}}',
      '{{cms:not_page:content}}',
      '{not_a_tag}'
    ].each do |tag_signature|
      assert_nil CmsTag::PageText.initialize_tag(cms_pages(:default), tag_signature)
    end
  end
  
  def test_content_and_render
    tag = CmsTag::PageText.initialize_tag(cms_pages(:default), '{{cms:page:content}}')
    assert tag.content.blank?
    tag.content = 'test_content'
    assert_equal 'test_content', tag.content
    assert_equal 'test_content', tag.render
  end
  
end