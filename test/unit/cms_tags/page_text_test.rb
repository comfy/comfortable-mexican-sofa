require File.dirname(__FILE__) + '/../../test_helper'

class PageTextTest < ActiveSupport::TestCase
  
  def test_regex_tag_signature
    %w(
      <cms:page:content:text/>
      <cms:page:content/>
      <cms:page:content>
      <cms:page:content:text>
    ).each do |tag|
      assert_match CmsTag::PageText.regex_tag_signature, tag
      assert_match CmsTag::PageText.regex_tag_signature('content'), tag
      assert_match cms_blocks(:default_page_text).regex_tag_signature, tag
    end
    
    assert_no_match CmsTag::PageText.regex_tag_signature, '<cms:page:header:string>'
    assert_no_match CmsTag::PageText.regex_tag_signature('something'), '<cms:page:header:text/>'
    assert_no_match CmsTag::PageText.regex_tag_signature, '<cms_page:header>'
  end
  
  def test_initialization_of_content_objects
    content = cms_layouts(:default).content
    block = CmsTag::PageText.initialize_tag_objects(content).first
    assert_equal CmsTag::PageText, block.class
  end
  
  def test_method_content
    block = cms_blocks(:default_page_text)
    assert_equal CmsTag::PageText, block.class
    assert_equal block.read_attribute(:content_text), block.content
    assert_equal block.content, block.render
  end
  
end