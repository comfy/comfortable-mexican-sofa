require File.dirname(__FILE__) + '/../test_helper'

class CmsPageTextContentTest < ActiveSupport::TestCase
  
  def test_regex_tag_signature
    %w(
      <cms:page:content:text/>
      <cms:page:content/>
      <cms:page:content>
      <cms:page:content:text>
    ).each do |tag|
      assert_match CmsPageTextContent.regex_tag_signature, tag
      assert_match CmsPageTextContent.regex_tag_signature('content'), tag
      assert_match cms_page_contents(:default).regex_tag_signature, tag
    end
    
    assert_no_match CmsPageTextContent.regex_tag_signature, '<cms:page:header:string>'
    assert_no_match CmsPageTextContent.regex_tag_signature('something'), '<cms:page:header:text/>'
    assert_no_match CmsPageTextContent.regex_tag_signature, '<cms_page:header>'
  end
  
  def test_initialization_of_content_objects
    content = cms_layouts(:default).content
    objects = CmsPageTextContent.initialize_content_objects(content)
    assert_equal 3, objects.size
    objects.each do |object|
      assert_equal CmsPageTextContent, object.class
      assert_not_nil object.label
    end
  end
  
end
