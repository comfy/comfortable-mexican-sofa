require File.dirname(__FILE__) + '/../../test_helper'

class PageStringTest < ActiveSupport::TestCase
  
  def test_regex_tag_signature
    %w(
      <cms:page:title:string/>
      <cms:page:title:string>
    ).each do |tag|
      assert_match CmsTag::PageString.regex_tag_signature, tag
      assert_match CmsTag::PageString.regex_tag_signature('title'), tag
      assert_match cms_blocks(:default_page_string).regex_tag_signature, tag
    end
    
    assert_no_match CmsTag::PageString.regex_tag_signature, '<cms:page:title:not_string>'
    assert_no_match CmsTag::PageString.regex_tag_signature('title'), '<cms:page:not_title:string/>'
    assert_no_match CmsTag::PageString.regex_tag_signature, '<cms_page:not_valid_tag>'
  end
  
  def test_initialization_of_content_objects
    content = cms_layouts(:default).content
    block = CmsTag::PageString.initialize_tag_objects(content).first
    assert_equal CmsTag::PageString, block.class
  end
  
  def test_method_content
    block = cms_blocks(:default_page_string)
    assert_equal CmsTag::PageString, block.class
    assert_equal block.read_attribute(:content_string), block.content
    assert_equal block.content, block.render
  end
  
end