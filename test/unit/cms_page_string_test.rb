require File.dirname(__FILE__) + '/../test_helper'

class CmsPageStringTest < ActiveSupport::TestCase
  
  def test_regex_tag_signature
    %w(
      <cms:page:title:string/>
      <cms:page:title:string>
    ).each do |tag|
      assert_match CmsPageString.regex_tag_signature, tag
      assert_match CmsPageString.regex_tag_signature('title'), tag
      assert_match cms_blocks(:string).regex_tag_signature, tag
    end
    
    assert_no_match CmsPageString.regex_tag_signature, '<cms:page:title:text>'
    assert_no_match CmsPageString.regex_tag_signature('something'), '<cms:page:title:string/>'
    assert_no_match CmsPageString.regex_tag_signature, '<cms_page:header>'
  end
  
  def test_initialization_of_content_objects
    content = cms_layouts(:default).content
    block = CmsPageString.initialize_content_blocks(content).first
    assert_equal CmsPageString, block.class
  end
  
  def test_method_content
    block = cms_blocks(:string)
    assert_equal CmsPageString, block.class
    assert_equal block.read_attribute(:content_string), block.content
    assert_equal block.content, block.render
  end
  
end
