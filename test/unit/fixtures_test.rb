# encoding: utf-8

require File.expand_path('../test_helper', File.dirname(__FILE__))

class FixturesTest < ActiveSupport::TestCase
  
  def test_import_layouts_creating
    Cms::Layout.delete_all
    
    assert_difference 'Cms::Layout.count', 2 do
      ComfortableMexicanSofa::Fixtures.import_layouts('default-site', 'sample-site')
      
      assert layout = Cms::Layout.find_by_identifier('default')
      assert_equal 'Default Fixture Layout', layout.label
      assert_equal "<html>\n  <body>\n    {{ cms:page:content }}\n  </body>\n</html>", layout.content.chomp
      assert_equal 'body{color: red}', layout.css
      assert_equal '// default js', layout.js
      assert_equal '<title>The Head</title>', layout.head.chomp
      
      assert nested_layout = Cms::Layout.find_by_identifier('nested')
      assert_equal layout, nested_layout.parent
      assert_equal 'Default Fixture Nested Layout', nested_layout.label
      assert_equal "<div class='left'> {{ cms:page:left }} </div>\n<div class='right'> {{ cms:page:right }} </div>", nested_layout.content.chomp
      assert_equal 'div{float:left}', nested_layout.css
      assert_equal '// nested js', nested_layout.js
    end
  end
  
  def test_import_layouts_updating_and_deleting
    layout        = cms_layouts(:default)
    nested_layout = cms_layouts(:nested)
    child_layout  = cms_layouts(:child)
    layout.update_column(:updated_at, 10.years.ago)
    nested_layout.update_column(:updated_at, 10.years.ago)
    child_layout.update_column(:updated_at, 10.years.ago)
    
    assert_difference 'Cms::Layout.count', -1 do
      ComfortableMexicanSofa::Fixtures.import_layouts('default-site', 'sample-site')
      
      layout.reload
      assert_equal 'Default Fixture Layout', layout.label
      assert_equal "<html>\n  <body>\n    {{ cms:page:content }}\n  </body>\n</html>", layout.content.chomp
      assert_equal 'body{color: red}', layout.css
      assert_equal '// default js', layout.js
      assert_equal '<title>The Head</title>', layout.head.chomp
      assert_equal 0, layout.position
      
      nested_layout.reload
      assert_equal layout, nested_layout.parent
      assert_equal 'Default Fixture Nested Layout', nested_layout.label
      assert_equal "<div class='left'> {{ cms:page:left }} </div>\n<div class='right'> {{ cms:page:right }} </div>", nested_layout.content.chomp
      assert_equal 'div{float:left}', nested_layout.css
      assert_equal '// nested js', nested_layout.js
      assert_equal 42, nested_layout.position
      
      assert_nil Cms::Layout.find_by_identifier('child')
    end
  end
  
  def test_import_layouts_ignoring
    layout = cms_layouts(:default)
    layout_path       = File.join(ComfortableMexicanSofa.config.fixtures_path, 'sample-site', 'layouts', 'default')
    attr_file_path    = File.join(layout_path, '_default.yml')
    content_file_path = File.join(layout_path, 'content.html')
    css_file_path     = File.join(layout_path, 'css.css')
    js_file_path      = File.join(layout_path, 'js.js')
    
    assert layout.updated_at >= File.mtime(attr_file_path)
    assert layout.updated_at >= File.mtime(content_file_path)
    assert layout.updated_at >= File.mtime(css_file_path)
    assert layout.updated_at >= File.mtime(js_file_path)
    
    ComfortableMexicanSofa::Fixtures.import_layouts('default-site', 'sample-site')
    layout.reload
    assert_equal 'default', layout.identifier
    assert_equal 'Default Layout', layout.label
    assert_equal "{{cms:field:default_field_text:text}}\nlayout_content_a\n{{cms:page:default_page_text:text}}\nlayout_content_b\n{{cms:snippet:default}}\nlayout_content_c", layout.content
    assert_equal 'default_css', layout.css
    assert_equal 'default_js', layout.js
  end
  
  def test_import_pages_creating
    Cms::Page.delete_all
    
    layout = cms_layouts(:default)
    layout.update_column(:content, '<html>{{cms:page:content}}</html>')
    
    nested = cms_layouts(:nested)
    nested.update_column(:content, '<html>{{cms:page:left}}<br/>{{cms:page:right}}</html>')
    
    assert_difference 'Cms::Page.count', 2 do
      ComfortableMexicanSofa::Fixtures.import_pages('default-site', 'sample-site')
      
      assert page = Cms::Page.find_by_full_path('/')
      assert_equal layout, page.layout
      assert_equal 'index', page.slug
      assert_equal "<html>Home Page Fixture Contént\ndefault_snippet_content</html>", page.content
      assert_equal 0, page.position
      assert page.is_published?
      
      assert child_page = Cms::Page.find_by_full_path('/child')
      assert_equal page, child_page.parent
      assert_equal nested, child_page.layout
      assert_equal 'child', child_page.slug
      assert_equal '<html>Child Page Left Fixture Content<br/>Child Page Right Fixture Content</html>', child_page.content
      assert_equal 42, child_page.position
    end
  end
  
  def test_import_pages_updating_and_deleting
    page = cms_pages(:default)
    page.update_column(:updated_at, 10.years.ago)
    assert_equal 'Default Page', page.label
    
    child = cms_pages(:child)
    child.update_column(:slug, 'old')
    
    ComfortableMexicanSofa::Fixtures.import_pages('default-site', 'sample-site')
    
    page.reload
    assert_equal 'Home Fixture Page', page.label
    
    assert_nil Cms::Page.find_by_slug('old')
  end
  
  def test_import_pages_ignoring
    Cms::Page.destroy_all
    
    page = cms_sites(:default).pages.create!(
      :label  => 'Test',
      :layout => cms_layouts(:default),
      :blocks_attributes => [ { :identifier => 'content', :content => 'test content' } ]
    )
    
    page_path         = File.join(ComfortableMexicanSofa.config.fixtures_path, 'sample-site', 'pages', 'index')
    attr_file_path    = File.join(page_path, '_index.yml')
    content_file_path = File.join(page_path, 'content.html')
    
    assert page.updated_at >= File.mtime(attr_file_path)
    assert page.updated_at >= File.mtime(content_file_path)
    
    ComfortableMexicanSofa::Fixtures.import_pages('default-site', 'sample-site')
    page.reload
    
    assert_equal nil, page.slug
    assert_equal 'Test', page.label
    block = page.blocks.where(:identifier => 'content').first
    assert_equal 'test content', block.content
  end
  
  def test_import_pages_removing_deleted_blocks
    Cms::Page.destroy_all
    
    page = cms_sites(:default).pages.create!(
      :label  => 'Test',
      :layout => cms_layouts(:default),
      :blocks_attributes => [ { :identifier => 'to_delete', :content => 'test content' } ]
    )
    page.update_column(:updated_at, 10.years.ago)
    
    ComfortableMexicanSofa::Fixtures.import_pages('default-site', 'sample-site')
    page.reload
    
    block = page.blocks.where(:identifier => 'content').first
    assert_equal "Home Page Fixture Contént\n{{ cms:snippet:default }}", block.content
    
    block = page.blocks.where(:identifier => 'to_delete').first
    assert_equal nil, block
  end
  
  def test_import_snippets_creating
    Cms::Snippet.delete_all
    
    assert_difference 'Cms::Snippet.count' do
      ComfortableMexicanSofa::Fixtures.import_snippets('default-site', 'sample-site')
      assert snippet = Cms::Snippet.last
      assert_equal 'default', snippet.identifier
      assert_equal 'Default Fixture Snippet', snippet.label
      assert_equal 'Fixture Content for Default Snippet', snippet.content
    end
  end
  
  def test_import_snippets_updating
    snippet = cms_snippets(:default)
    snippet.update_column(:updated_at, 10.years.ago)
    assert_equal 'default', snippet.identifier
    assert_equal 'Default Snippet', snippet.label
    assert_equal 'default_snippet_content', snippet.content
    
    assert_no_difference 'Cms::Snippet.count' do
      ComfortableMexicanSofa::Fixtures.import_snippets('default-site', 'sample-site')
      snippet.reload
      assert_equal 'default', snippet.identifier
      assert_equal 'Default Fixture Snippet', snippet.label
      assert_equal 'Fixture Content for Default Snippet', snippet.content
    end
  end
  
  def test_import_snippets_deleting
    snippet = cms_snippets(:default)
    snippet.update_column(:identifier, 'old')
    
    assert_no_difference 'Cms::Snippet.count' do
      ComfortableMexicanSofa::Fixtures.import_snippets('default-site', 'sample-site')
      assert snippet = Cms::Snippet.last
      assert_equal 'default', snippet.identifier
      assert_equal 'Default Fixture Snippet', snippet.label
      assert_equal 'Fixture Content for Default Snippet', snippet.content
      
      assert_nil Cms::Snippet.find_by_identifier('old')
    end
  end
  
  def test_import_snippets_ignoring
    snippet = cms_snippets(:default)
    snippet_path      = File.join(ComfortableMexicanSofa.config.fixtures_path, 'sample-site', 'snippets', 'default')
    attr_file_path    = File.join(snippet_path, '_default.yml')
    content_file_path = File.join(snippet_path, 'content.html')
    
    assert snippet.updated_at >= File.mtime(attr_file_path)
    assert snippet.updated_at >= File.mtime(content_file_path)
    
    ComfortableMexicanSofa::Fixtures.import_snippets('default-site', 'sample-site')
    snippet.reload
    assert_equal 'default', snippet.identifier
    assert_equal 'Default Snippet', snippet.label
    assert_equal 'default_snippet_content', snippet.content
  end

  def test_import_files_creating
    Cms::File.delete_all
    
    assert_difference 'Cms::File.count' do
      ComfortableMexicanSofa::Fixtures.import_files('default-site', 'sample-site')
      assert file = Cms::File.last
      assert_equal 'default', file.label
      assert_equal 'Default Fixture File', file.description
      assert_equal 'image.jpg', file.file_file_name
    end
  end

  def test_import_files_updating
    file = cms_files(:default)
    file.update_column(:updated_at, 10.years.ago)
    assert_equal 'default', file.label
    assert_equal 'Description', file.description
    assert_equal 'sample.jpg', file.file_file_name
    
    assert_no_difference 'Cms::File.count' do
      ComfortableMexicanSofa::Fixtures.import_files('default-site', 'sample-site')
      file.reload
      assert_equal 'default', file.label
      assert_equal 'Default Fixture File', file.description
      assert_equal 'image.jpg', file.file_file_name
    end
  end
  
  def test_import_files_deleting
    file = cms_files(:default)
    file.update_column(:label, 'old')
    
    assert_no_difference 'Cms::File.count' do
      ComfortableMexicanSofa::Fixtures.import_files('default-site', 'sample-site')
      assert file = Cms::File.last
      assert_equal 'default', file.label
      assert_equal 'Default Fixture File', file.description
      assert_equal 'image.jpg', file.file_file_name
      
      assert_nil Cms::File.find_by_label('old')
    end
  end
  
  def test_import_files_ignoring
    file = cms_files(:default)
    file_path         = File.join(ComfortableMexicanSofa.config.fixtures_path, 'sample-site', 'files', 'default')
    attr_file_path    = File.join(file_path, '_default.yml')
    file_file_path    = File.join(file_path, 'image.jpg')
    
    assert file.updated_at >= File.mtime(attr_file_path)
    assert file.updated_at >= File.mtime(file_file_path)
    
    ComfortableMexicanSofa::Fixtures.import_files('default-site', 'sample-site')
    file.reload
    assert_equal 'default', file.label
    assert_equal 'Description', file.description
    assert_equal 'sample.jpg', file.file_file_name
  end
  
  def test_import_all
    Cms::Page.destroy_all
    Cms::Layout.destroy_all
    Cms::Snippet.destroy_all
    Cms::File.destroy_all
    
    assert_difference 'Cms::Layout.count', 2 do
      assert_difference 'Cms::Page.count', 2 do
        assert_difference 'Cms::Snippet.count', 1 do
          assert_difference 'Cms::File.count', 1 do
            ComfortableMexicanSofa::Fixtures.import_all('default-site', 'sample-site')
          end
        end
      end
    end
  end
  
  def test_import_all_with_no_site
    cms_sites(:default).destroy
    
    assert_difference 'Cms::Site.count', 1 do
      assert_difference 'Cms::Layout.count', 2 do
        assert_difference 'Cms::Page.count', 2 do
          assert_difference 'Cms::Snippet.count', 1 do
            assert_difference 'Cms::File.count', 1 do
              ComfortableMexicanSofa::Fixtures.import_all('default-site', 'sample-site')
            end
          end
        end
      end
    end
  end
  
  def test_export_layouts
    host_path = File.join(ComfortableMexicanSofa.config.fixtures_path, 'test-site')
    layout_1_attr_path    = File.join(host_path, 'layouts/nested/_nested.yml')
    layout_1_content_path = File.join(host_path, 'layouts/nested/content.html')
    layout_1_css_path     = File.join(host_path, 'layouts/nested/css.css')
    layout_1_js_path      = File.join(host_path, 'layouts/nested/js.js')
    layout_1_head_path    = File.join(host_path, 'layouts/nested/head.html')
    layout_2_attr_path    = File.join(host_path, 'layouts/nested/child/_child.yml')
    layout_2_content_path = File.join(host_path, 'layouts/nested/child/content.html')
    layout_2_css_path     = File.join(host_path, 'layouts/nested/child/css.css')
    layout_2_js_path      = File.join(host_path, 'layouts/nested/child/js.js')
    
    ComfortableMexicanSofa::Fixtures.export_layouts('default-site', 'test-site')
    
    assert File.exists?(layout_1_attr_path)
    assert File.exists?(layout_1_content_path)
    assert File.exists?(layout_1_css_path)
    assert File.exists?(layout_1_js_path)
    assert File.exists?(layout_1_head_path)
    
    assert File.exists?(layout_2_attr_path)
    assert File.exists?(layout_2_content_path)
    assert File.exists?(layout_2_css_path)
    assert File.exists?(layout_2_js_path)
    
    assert_equal ({
      'label'       => 'Nested Layout',
      'app_layout'  => nil,
      'parent'      => nil,
      'position'    => 0
    }), YAML.load_file(layout_1_attr_path)
    assert_equal cms_layouts(:nested).content, IO.read(layout_1_content_path)
    assert_equal cms_layouts(:nested).css, IO.read(layout_1_css_path)
    assert_equal cms_layouts(:nested).js, IO.read(layout_1_js_path)
    assert_equal cms_layouts(:nested).head, IO.read(layout_1_head_path)
    
    assert_equal ({
      'label'       => 'Child Layout',
      'app_layout'  => nil,
      'parent'      => 'nested',
      'position'    => 0
    }), YAML.load_file(layout_2_attr_path)
    assert_equal cms_layouts(:child).content, IO.read(layout_2_content_path)
    assert_equal cms_layouts(:child).css, IO.read(layout_2_css_path)
    assert_equal cms_layouts(:child).js, IO.read(layout_2_js_path)
    
    FileUtils.rm_rf(host_path)
  end
  
  def test_export_pages
    host_path = File.join(ComfortableMexicanSofa.config.fixtures_path, 'test-site')
    page_1_attr_path    = File.join(host_path, 'pages/index/_index.yml')
    page_1_block_a_path = File.join(host_path, 'pages/index/default_field_text.html')
    page_1_block_b_path = File.join(host_path, 'pages/index/default_page_text.html')
    page_2_attr_path    = File.join(host_path, 'pages/index/child-page/_child-page.yml')
    
    ComfortableMexicanSofa::Fixtures.export_pages('default-site', 'test-site')
    
    assert_equal ({
      'label'          => 'Default Page',
      'layout'         => 'default',
      'parent'         => nil,
      'target_page'    => nil,
      'is_published'   => true,
      "include_in_nav" => true,
      'position'       => 0
    }), YAML.load_file(page_1_attr_path)
    assert_equal cms_blocks(:default_field_text).content, IO.read(page_1_block_a_path)
    assert_equal cms_blocks(:default_page_text).content, IO.read(page_1_block_b_path)
    
    assert_equal ({
      'label'           => 'Child Page',
      'layout'          => 'default',
      'parent'          => 'index',
      'target_page'     => nil,
      'is_published'    => true,
      "include_in_nav"  => true,
      'position'        => 0
    }), YAML.load_file(page_2_attr_path)
    
    FileUtils.rm_rf(host_path)
  end
  
  def test_export_snippets
    host_path = File.join(ComfortableMexicanSofa.config.fixtures_path, 'test-site')
    attr_path     = File.join(host_path, 'snippets/default/_default.yml')
    content_path  = File.join(host_path, 'snippets/default/content.html')
    
    ComfortableMexicanSofa::Fixtures.export_snippets('default-site', 'test-site')
    
    assert File.exists?(attr_path)
    assert File.exists?(content_path)
    assert_equal ({'label' => 'Default Snippet'}), YAML.load_file(attr_path)
    assert_equal cms_snippets(:default).content, IO.read(content_path)
    
    FileUtils.rm_rf(host_path)
  end

  def test_export_files
    host_path = File.join(ComfortableMexicanSofa.config.fixtures_path, 'test-site')
    attr_path     = File.join(host_path, 'files/default/_default.yml')
    file_path     = File.join(host_path, 'files/default/image.jpg')
    label = 'default'

    f = Cms::File.find_by_label(label)
    f.file = File.open(Rails.root.join("test", "fixtures", "files", "image.jpg"))
    f.save!
    
    ComfortableMexicanSofa::Fixtures.export_files('default-site', 'test-site')
    
    assert File.exists?(attr_path)
    assert File.exists?(file_path)
    assert_equal ({:label => label, :description => 'Description', :file => 'image.jpg'}), YAML.load_file(attr_path)
    
    FileUtils.rm_rf(host_path)
  end
  
  def test_export_all
    host_path = File.join(ComfortableMexicanSofa.config.fixtures_path, 'test-site')

    # Did no-one ever tell you not to talk to fixtures?
    f = Cms::File.find_by_label('default')
    f.file = File.open(Rails.root.join("test", "fixtures", "files", "image.jpg"))
    f.save!

    ComfortableMexicanSofa::Fixtures.export_all('default-site', 'test-site')
    FileUtils.rm_rf(host_path)
  end
  
end
