require_relative '../test_helper'

class RevisionsTest < ActiveSupport::TestCase
  
  def test_fixtures_validity
    assert_equal ({
      'content' => 'revision {{cms:page:default_page_text}}', 
      'css'     => 'revision css',
      'js'      => 'revision js' }), cms_revisions(:layout).data
      
    assert_equal ({'blocks_attributes' => [
      { 'identifier' => 'default_page_text',   'content' => 'revision page content'  },
      { 'identifier' => 'default_field_text',  'content' => 'revision field content' }
    ]}), cms_revisions(:page).data
    
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
      revision = layout.revisions.first
      assert_equal old_attributes, revision.data
    end
  end
  
  def test_creation_for_layout_ignore
    layout = cms_layouts(:default)
    assert_no_difference 'layout.revisions.count' do
      layout.update_attributes(:label => 'new label')
    end
  end
  
  def test_creation_for_page
    page = cms_pages(:default)
    
    assert_difference 'page.revisions.count' do
      page.update_attributes!(
        :blocks_attributes => [
          { :identifier => 'default_page_text',
            :content    => 'new content' }
        ]
      )
      page.reload
      assert_equal 2, page.revisions.count
      revision = page.revisions.first
      assert_equal ({
        'blocks_attributes' => [
          { :identifier => 'default_field_text',
            :content    => 'default_field_text_content' },
          { :identifier => 'default_page_text',
            :content    => "default_page_text_content_a\n{{cms:snippet:default}}\ndefault_page_text_content_b" }]
      }), revision.data
    end
  end
  
  def test_creation_for_page_ignore
    page = cms_pages(:default)
    assert_no_difference 'page.revisions.count' do
      page.update_attributes(:label => 'new label')
    end
  end
  
  def test_creation_for_snippet
    snippet = cms_snippets(:default)
    old_attributes  = snippet.attributes.slice('content')
    
    assert_difference 'snippet.revisions.count' do
      snippet.update_attributes(:content => 'new content')
      snippet.reload
      assert_equal 2, snippet.revisions.count
      revision = snippet.revisions.first
      assert_equal old_attributes, revision.data
    end
  end
  
  def test_creation_for_snippet_ignore
    snippet = cms_snippets(:default)
    assert_no_difference 'snippet.revisions.count' do
      snippet.update_attributes(:label => 'new label')
    end
  end
  
  def test_creation_for_new_record
    assert_difference 'Cms::Snippet.count' do
      assert_no_difference 'Cms::Revision.count' do
        snippet = cms_sites(:default).snippets.create!(
          :label      => 'test snippet',
          :identifier => 'test_snippet',
          :content    => 'test content'
        )
        assert_equal 0, snippet.revisions.count
      end
    end
  end
  
  def test_restore_from_revision_for_layout
    layout = cms_layouts(:default)
    revision = cms_revisions(:layout)
    
    assert_difference 'layout.revisions.count' do
      layout.restore_from_revision(revision)
      layout.reload
      assert_equal 'revision {{cms:page:default_page_text}}', layout.content
      assert_equal 'revision css', layout.css
      assert_equal 'revision js', layout.js
    end
  end
  
  def test_restore_from_revision_for_page
    page = cms_pages(:default)
    revision = cms_revisions(:page)
    
    assert_difference 'page.revisions.count' do
      page.restore_from_revision(revision)
      page.reload
      assert_equal [
        { :identifier => 'default_field_text', :content => 'revision field content'  },
        { :identifier => 'default_page_text',  :content => 'revision page content'   }
      ], page.blocks_attributes
    end
  end
  
  def test_restore_from_revision_for_snippet
    snippet = cms_snippets(:default)
    revision = cms_revisions(:snippet)
    
    assert_difference 'snippet.revisions.count' do
      snippet.restore_from_revision(revision)
      snippet.reload
      assert_equal 'revision content', snippet.content
    end
  end
  
  def test_restore_from_revision_with_wrong_revision_type
    snippet = cms_snippets(:default)
    revision = cms_revisions(:layout)
    
    assert_no_difference 'snippet.revisions.count' do
      snippet.restore_from_revision(revision)
      snippet.reload
      assert_equal 'default_snippet_content', snippet.content
    end
  end
  
  def test_creation_with_limit
    ComfortableMexicanSofa.config.revisions_limit = 1
    snippet = cms_snippets(:default)
    revision = cms_revisions(:snippet)
    
    assert_equal 1, snippet.revisions.count
    
    assert_no_difference 'snippet.revisions.count' do
      snippet.update_attributes(:content => 'new content')
      assert_nil Cms::Revision.find_by_id(revision.id)
      
      snippet.reload
      revision = snippet.revisions.first
      assert_equal ({ 'content' => 'default_snippet_content' }), revision.data
    end
  end
  
end