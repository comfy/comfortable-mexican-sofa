require File.expand_path('../test_helper', File.dirname(__FILE__))

class RevisionsTest < ActiveSupport::TestCase
  
  def test_fixtures_validity
    assert_equal ({
      'content' => 'revision content', 
      'css'     => 'revision css',
      'js'      => 'revision js' }), cms_revisions(:layout).data
      
    assert_equal ([
      { 'label' => 'default_page_text',   'content' => 'revision page content'  },
      { 'label' => 'default_field_text',  'content' => 'revision field content' }
    ]), cms_revisions(:page).data
    
    assert_equal ({
      'content' => 'revision content'
    }), cms_revisions(:snippet).data
  end
  
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