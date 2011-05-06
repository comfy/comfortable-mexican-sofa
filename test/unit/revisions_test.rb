require File.expand_path('../test_helper', File.dirname(__FILE__))

class RevisionsTest < ActiveSupport::TestCase
  
  def test_fixtures_validity
    assert_equal ({
      'content' => 'revision {{cms:page:default_page_text}}', 
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
    assert_equal ['content', 'css', 'js'], cms_layouts(:default).revision_fields
  end
  
  def test_init_for_pages
    assert_equal ['blocks_attributes'], cms_pages(:default).revision_fields
  end
  
  def test_init_for_snippets
    assert_equal ['content'], cms_snippets(:default).revision_fields
  end
  
  def test_creation_for_layout
    layout = cms_layouts(:default)
    old_attributes = layout.attributes.slice('content', 'css', 'js')
    
    assert_difference 'layout.revisions.count' do
      layout.update_attributes!(
        :content  => 'new {{cms:page:content}}',
        :js       => 'new js'
      )
      layout.reload
      assert_equal 2, layout.revisions.count
      revision = layout.revisions.last
      assert_equal old_attributes, revision.data
    end
  end
  
  def test_creation_for_layout_ignore
    layout = cms_layouts(:default)
    assert_no_difference 'layout.revisions.count' do
      layout.update_attribute(:label, 'new label')
    end
  end
  
  def test_creation_for_page
    page = cms_pages(:default)
    
    assert_difference 'page.revisions.count' do
      page.update_attributes!(
        :blocks_attributes => [
          { :label    => 'default_page_text',
            :content  => 'new content' }
        ]
      )
      page.reload
      assert_equal 2, page.revisions.count
      revision = page.revisions.last
      assert_equal ({
        'blocks_attributes' => [
          { :label    => 'default_field_text',
            :content  => 'default_field_text_content' },
          { :label    => 'default_page_text',
            :content  => "default_page_text_content_a\n{{cms:snippet:default}}\ndefault_page_text_content_b" }]
      }), revision.data
    end
  end
  
  def test_creation_for_page_ignore
    page = cms_pages(:default)
    assert_no_difference 'page.revisions.count' do
      page.update_attribute(:label, 'new label')
    end
  end
  
  def test_creation_for_snippet
    snippet = cms_snippets(:default)
    old_attributes  = snippet.attributes.slice('content')
    
    assert_difference 'snippet.revisions.count' do
      snippet.update_attribute(:content, 'new content')
      snippet.reload
      assert_equal 2, snippet.revisions.count
      revision = snippet.revisions.last
      assert_equal old_attributes, revision.data
    end
  end
  
  def test_creation_for_snippet_ignore
    snippet = cms_snippets(:default)
    assert_no_difference 'snippet.revisions.count' do
      snippet.update_attribute(:label, 'new label')
    end
  end
  
end