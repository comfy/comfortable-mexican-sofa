require File.expand_path('../test_helper', File.dirname(__FILE__))

class ViewMethodsTest < ActiveSupport::TestCase
  
  def setup
    @site = cms_sites(:default)
    @site.update_attribute(:hostname, 'example.com')
  end
  
  def test_sync
    Cms::Page.destroy_all
    Cms::Layout.destroy_all
    Cms::Snippet.destroy_all
    
    assert_difference 'Cms::Layout.count', 2 do
      assert_difference 'Cms::Page.count', 2 do
        assert_difference 'Cms::Snippet.count', 1 do
          ComfortableMexicanSofa::Fixtures.sync(@site)
        end
      end
    end
  end
  
  def test_sync_layouts_creating
    Cms::Layout.delete_all
    
    assert_difference 'Cms::Layout.count', 2 do
      ComfortableMexicanSofa::Fixtures.sync_layouts(@site)
      assert layout = Cms::Layout.find_by_slug('default')
      assert_equal 'Default Fixture Layout', layout.label
      assert_equal "<html>\n  <body>\n    {{ cms:page:content }}\n  </body>\n</html>", layout.content
      assert_equal 'body{color: red}', layout.css
      assert_equal '// default js', layout.js
      
      assert nested_layout = Cms::Layout.find_by_slug('nested')
      assert_equal layout, nested_layout.parent
      assert_equal 'Default Fixture Nested Layout', nested_layout.label
      assert_equal "<div class='left'> {{ cms:page:left }} </div>\n<div class='right'> {{ cms:page:right }} </div>", nested_layout.content
      assert_equal 'div{float:left}', nested_layout.css
      assert_equal '// nested js', nested_layout.js
    end
  end
  
  def test_sync_layouts_updating_and_deleting
    
    layout        = cms_layouts(:default)
    nested_layout = cms_layouts(:nested)
    child_layout  = cms_layouts(:child)
    layout.update_attribute(:updated_at, 10.years.ago)
    nested_layout.update_attribute(:updated_at, 10.years.ago)
    child_layout.update_attribute(:updated_at, 10.years.ago)
    
    assert_difference 'Cms::Layout.count', -1 do
      ComfortableMexicanSofa::Fixtures.sync_layouts(@site)
      
      layout.reload
      assert_equal 'Default Fixture Layout', layout.label
      assert_equal "<html>\n  <body>\n    {{ cms:page:content }}\n  </body>\n</html>", layout.content
      assert_equal 'body{color: red}', layout.css
      assert_equal '// default js', layout.js
      
      nested_layout.reload
      assert_equal layout, nested_layout.parent
      assert_equal 'Default Fixture Nested Layout', nested_layout.label
      assert_equal "<div class='left'> {{ cms:page:left }} </div>\n<div class='right'> {{ cms:page:right }} </div>", nested_layout.content
      assert_equal 'div{float:left}', nested_layout.css
      assert_equal '// nested js', nested_layout.js
      
      assert_nil Cms::Layout.find_by_slug('child')
    end
  end
  
  def test_sync_layouts_ignoring
    layout = cms_layouts(:default)
    layout_path       = File.join(ComfortableMexicanSofa.config.fixtures_path, @site.hostname, 'layouts', 'default')
    attr_file_path    = File.join(layout_path, '_default.yml')
    content_file_path = File.join(layout_path, 'content.html')
    css_file_path     = File.join(layout_path, 'css.css')
    js_file_path      = File.join(layout_path, 'js.js')
    
    assert layout.updated_at >= File.mtime(attr_file_path)
    assert layout.updated_at >= File.mtime(content_file_path)
    assert layout.updated_at >= File.mtime(css_file_path)
    assert layout.updated_at >= File.mtime(js_file_path)
    
    ComfortableMexicanSofa::Fixtures.sync_layouts(@site)
    layout.reload
    assert_equal 'default', layout.slug
    assert_equal 'Default Layout', layout.label
    assert_equal "{{cms:field:default_field_text:text}}\nlayout_content_a\n{{cms:page:default_page_text:text}}\nlayout_content_b\n{{cms:snippet:default}}\nlayout_content_c", layout.content
    assert_equal 'default_css', layout.css
    assert_equal 'default_js', layout.js
  end
  
  def test_sync_pages_creating
    Cms::Page.delete_all
    
    layout = cms_layouts(:default)
    layout.update_attribute(:content, '<html>{{cms:page:content}}</html>')
    
    nested = cms_layouts(:nested)
    nested.update_attribute(:content, '<html>{{cms:page:left}}<br/>{{cms:page:right}}</html>')
    
    assert_difference 'Cms::Page.count', 2 do
      ComfortableMexicanSofa::Fixtures.sync_pages(@site)
      
      assert page = Cms::Page.find_by_full_path('/')
      assert_equal layout, page.layout
      assert_equal 'index', page.slug
      assert_equal "<html>Home Page Fixture Content\ndefault_snippet_content</html>", page.content
      assert page.is_published?
      
      assert child_page = Cms::Page.find_by_full_path('/child')
      assert_equal page, child_page.parent
      assert_equal nested, child_page.layout
      assert_equal 'child', child_page.slug
      assert_equal '<html>Child Page Left Fixture Content<br/>Child Page Right Fixture Content</html>', child_page.content
    end
  end
  
  def test_sync_pages_updating_and_deleting
    page = cms_pages(:default)
    page.update_attribute(:updated_at, 10.years.ago)
    assert_equal 'Default Page', page.label
    
    child = cms_pages(:child)
    child.update_attribute(:slug, 'old')
    
    assert_no_difference 'Cms::Page.count' do
      ComfortableMexicanSofa::Fixtures.sync_pages(@site)
      
      page.reload
      assert_equal 'Home Fixture Page', page.label
      
      assert_nil Cms::Page.find_by_slug('old')
    end
  end
  
  def test_sync_pages_ignoring
    page = cms_pages(:default)
    page_path         = File.join(ComfortableMexicanSofa.config.fixtures_path, @site.hostname, 'pages', 'index')
    attr_file_path    = File.join(page_path, '_index.yml')
    content_file_path = File.join(page_path, 'content.html')
    
    assert page.updated_at >= File.mtime(attr_file_path)
    assert page.updated_at >= File.mtime(content_file_path)
    
    ComfortableMexicanSofa::Fixtures.sync_pages(@site)
    page.reload
    assert_equal nil, page.slug
    assert_equal 'Default Page', page.label
    assert_equal "\nlayout_content_a\ndefault_page_text_content_a\ndefault_snippet_content\ndefault_page_text_content_b\nlayout_content_b\ndefault_snippet_content\nlayout_content_c", page.content
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
    snippet_path      = File.join(ComfortableMexicanSofa.config.fixtures_path, @site.hostname, 'snippets', 'default')
    attr_file_path    = File.join(snippet_path, '_default.yml')
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