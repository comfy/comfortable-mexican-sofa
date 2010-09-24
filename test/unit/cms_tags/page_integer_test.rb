require File.dirname(__FILE__) + '/../../test_helper'

class PageIntegerTest < ActiveSupport::TestCase
  
  def test_initialize_tag
    %w(
      <cms:page:content:integer/>
      <cms:page:content:integer>
    ).each do |tag_signature|
      assert tag = CmsTag::PageInteger.initialize_tag(cms_pages(:default), tag_signature)
      assert_equal 'content', tag.label
    end
  end
  
  def test_initialize_tag_failure
    %w(
      <cms:page:content:not_integer/>
      <cms:page:content/>
      <cms:not_page:content/>
      not_a_tag
    ).each do |tag_signature|
      assert_nil CmsTag::PageInteger.initialize_tag(cms_pages(:default), tag_signature)
    end
  end
  
  def test_content_and_render
    tag = CmsTag::PageInteger.initialize_tag(cms_pages(:default), "<cms:page:content:integer>")
    assert tag.content.blank?
    tag.content = '5'
    assert_equal 5, tag.content
    assert_equal 5, tag.read_attribute(:content_integer)
    assert_equal '5', tag.render
  end
  
end