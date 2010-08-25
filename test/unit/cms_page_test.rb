require File.dirname(__FILE__) + '/../test_helper'

class CmsPageTest < ActiveSupport::TestCase
  
  def test_render
    page = cms_pages(:default)
    assert_equal [
      'default_page_text_content',
      'default_page_string_content',
      '1'
    ].join("\n"), page.render_content
  end
  
  def test_method_layout_content
    page = cms_pages(:default)
    assert_equal page.cms_layout.content, (content = page.send(:layout_content))
    content = 'new content'
    assert_not_equal page.cms_layout.content, content
  end
  
end
