require File.dirname(__FILE__) + '/../../test_helper'

class PageTextTest < ActiveSupport::TestCase
  
  def test_initialize_tag
    %w(
      <cms:page:content:text/>
      <cms:page:content/>
      <cms:page:content>
      <cms:page:content:text>
    ).each do |tag_signature|
      assert tag = CmsTag::PageText.initialize_tag(nil, tag_signature)
      assert_equal 'content', tag.label
    end
  end
  
  def test_initialize_tag_failure
    %w(
      <cms:page:content:not_text/>
      <cms:not_page:content/>
      not_a_tag
    ).each do |tag_signature|
      assert_nil CmsTag::PageText.initialize_tag(nil, tag_signature)
    end
  end
  
end