require File.dirname(__FILE__) + '/../../test_helper'

class PageIntegerTest < ActiveSupport::TestCase
  
  def test_regex_tag_signature
    %w(
      <cms:page:number:integer/>
      <cms:page:number:integer>
    ).each do |tag|
      assert_match CmsTag::PageInteger.regex_tag_signature, tag
      assert_match CmsTag::PageInteger.regex_tag_signature('number'), tag
      assert_match cms_blocks(:default_page_integer).regex_tag_signature, tag
    end
    
    assert_no_match CmsTag::PageInteger.regex_tag_signature, '<cms:page:number:not_integer>'
    assert_no_match CmsTag::PageInteger.regex_tag_signature('something'), '<cms:page:not_number:number/>'
    assert_no_match CmsTag::PageInteger.regex_tag_signature, '<cms_page:not_valid_tag>'
  end
  
  def test_initialization_of_content_objects
    content = cms_layouts(:default).content
    block = CmsTag::PageInteger.initialize_tag_objects(content).first
    assert_equal CmsTag::PageInteger, block.class
  end
  
  def test_method_content
    block = cms_blocks(:default_page_integer)
    assert_equal CmsTag::PageInteger, block.class
    assert_equal block.read_attribute(:content_integer), block.content
    assert_equal block.content, block.render
  end
  
end