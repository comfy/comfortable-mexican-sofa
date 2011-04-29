require File.expand_path('../test_helper', File.dirname(__FILE__))

class ViewMethodsTest < ActiveSupport::TestCase
  
  def setup
    @site = cms_sites(:default)
    @site.update_attribute(:hostname, 'example.com')
  end
  
  def test_sync_layouts_creating
    ComfortableMexicanSofa::Fixtures.sync_layouts(@site)
  end
  
  def test_sync_layouts_updating
    flunk
  end
  
  def test_sync_layouts_deleting
    flunk
  end
  
  def test_sync_layouts_ignoring
    flunk
  end
  
  def test_sync_pages_creating
    flunk
  end
  
  def test_sync_pages_updating
    flunk
  end
  
  def test_sync_pages_deleting
    flunk
  end
  
  def test_sync_pages_ignoring
    flunk
  end
  
  def test_sync_snippets_creating
    Cms::Snippet.delete_all
    
    assert_difference 'Cms::Snippet.count' do
      ComfortableMexicanSofa::Fixtures.sync_snippets(@site)
      assert snippet = Cms::Snippet.last
      assert_equal 'default', snippet.slug
      assert_equal 'Default Fixture Snippet', snippet.label
      assert_equal 'Fixture Content for Default Snippet', snippet.content
    end
  end
  
  def test_sync_snippets_updating
    snippet = cms_snippets(:default)
    snippet.update_attribute(:updated_at, 10.years.ago)
    assert_equal 'default', snippet.slug
    assert_equal 'Default Snippet', snippet.label
    assert_equal 'default_snippet_content', snippet.content
    
    assert_no_difference 'Cms::Snippet.count' do
      ComfortableMexicanSofa::Fixtures.sync_snippets(@site)
      snippet.reload
      assert_equal 'default', snippet.slug
      assert_equal 'Default Fixture Snippet', snippet.label
      assert_equal 'Fixture Content for Default Snippet', snippet.content
    end
  end
  
  def test_sync_snippets_deleting
    snippet = cms_snippets(:default)
    snippet.update_attribute(:slug, 'old')
    
    assert_no_difference 'Cms::Snippet.count' do
      ComfortableMexicanSofa::Fixtures.sync_snippets(@site)
      assert snippet = Cms::Snippet.last
      assert_equal 'default', snippet.slug
      assert_equal 'Default Fixture Snippet', snippet.label
      assert_equal 'Fixture Content for Default Snippet', snippet.content
      
      assert_nil Cms::Snippet.find_by_slug('old')
    end
  end
  
  def test_sync_snippets_ignoring
    snippet = cms_snippets(:default)
    snippet_path = File.join(ComfortableMexicanSofa.config.fixtures_path, @site.hostname, 'snippets', 'default')
    attr_file_path = File.join(snippet_path, '_default.yml')
    content_file_path = File.join(snippet_path, 'content.html')
    
    assert snippet.updated_at >= File.mtime(attr_file_path)
    assert snippet.updated_at >= File.mtime(content_file_path)
    
    ComfortableMexicanSofa::Fixtures.sync_snippets(@site)
    snippet.reload
    assert_equal 'default', snippet.slug
    assert_equal 'Default Snippet', snippet.label
    assert_equal 'default_snippet_content', snippet.content
  end
  
end