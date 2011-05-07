require File.expand_path('../test_helper', File.dirname(__FILE__))

class ViewMethodsTest < ActiveSupport::TestCase
  
  include ComfortableMexicanSofa::ViewMethods
  
  def test_cms_snippet_content
    assert_equal 'default_snippet_content', cms_snippet_content('default', cms_sites(:default))
    assert_equal '', cms_snippet_content('not_found', cms_sites(:default))
  end
  
  def test_cms_snippet_cotnent_with_tags
    snippet = cms_snippets(:default)
    snippet.update_attribute(:content, 'content {{cms:helper:test}}')
    assert_equal 'content <%= test() %>', cms_snippet_content(:default, cms_sites(:default))
  end
  
  def test_cms_page_content
    assert_equal 'default_field_text_content', cms_page_content('default_field_text', cms_pages(:default))
    assert_equal '', cms_page_content('default_field_text')
    @cms_page = cms_pages(:default)
    assert_equal 'default_field_text_content', cms_page_content('default_field_text')
    assert_equal '', cms_page_content('not_found')
    @cms_page = nil
  end
  
  def test_cms_page_content_with_tags
    block = cms_blocks(:default_field_text)
    block.update_attribute(:content, 'content {{cms:helper:test}}')
    assert_equal 'content <%= test() %>', cms_page_content(:default_field_text, cms_pages(:default))
  end
  
end