require File.dirname(__FILE__) + '/../test_helper'

class CmsPageTextContentTest < ActiveSupport::TestCase
  
  def test_regex_tag_signature
    %w(
      <cms:page:header:text/>
      <cms:page:header/>
      <cms:page:header>
      <cms:page:header:text>
    ).each do |tag|
      assert_match CmsPageTextContent.regex_tag_signature, tag
      assert_match CmsPageTextContent.regex_tag_signature('header'), tag
    end
    
    assert_no_match CmsPageTextContent.regex_tag_signature, '<cms:page:header:string>'
    assert_no_match CmsPageTextContent.regex_tag_signature('something'), '<cms:page:header:text/>'
    assert_no_match CmsPageTextContent.regex_tag_signature, '<cms_page:header>'
  end
  
end
