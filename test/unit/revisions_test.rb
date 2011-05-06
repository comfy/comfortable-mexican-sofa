require File.expand_path('../test_helper', File.dirname(__FILE__))

class RevisionsTest < ActiveSupport::TestCase
  
  def test_init_for_layouts
    assert_equal [:content, :css, :js], cms_layouts(:default).revision_fields
  end
  
  def test_init_for_pages
    assert_equal [:blocks_attributes], cms_pages(:default).revision_fields
  end
  
  def test_init_for_snippets
    assert_equal [:content], cms_snippets(:default).revision_fields
  end
  
end