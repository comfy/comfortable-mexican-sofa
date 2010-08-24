require File.dirname(__FILE__) + '/../test_helper'

class CmsFieldTextTest < ActiveSupport::TestCase
  
  def test_regex_tag_signature
    %w(
      <cms:field:keywords:text/>
      <cms:field:keywords:text>
    ).each do |tag|
      assert_match CmsPageText.regex_tag_signature, tag
      assert_match CmsPageText.regex_tag_signature('keywords'), tag
      assert_match cms_blocks(:default).regex_tag_signature, tag
    end
    
    assert_no_match CmsPageText.regex_tag_signature, '<cms:page:header:string>'
    assert_no_match CmsPageText.regex_tag_signature('something'), '<cms:page:header:text/>'
    assert_no_match CmsPageText.regex_tag_signature, '<cms_page:header>'
  end
  
  def test_initialization_of_content_objects
    content = cms_layouts(:default).content
    block = CmsPageText.initialize_content_blocks(content).first
    assert_equal CmsPageText, block.class
  end
  
  def test_method_content
    block = cms_blocks(:default)
    assert_equal CmsPageText, block.class
    assert_equal block.read_attribute(:content_text), block.content
    assert_equal block.content, block.render
  end
  
end
