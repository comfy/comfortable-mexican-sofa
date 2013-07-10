# encoding: utf-8

require_relative '../../test_helper'

class FixtureLayoutsTest < ActiveSupport::TestCase
  
  def test_creation
    Cms::Layout.delete_all
    
    assert_difference 'Cms::Layout.count', 2 do
      ComfortableMexicanSofa::Fixture::Layout::Importer.new('sample-site', 'default-site').import!
      
      assert layout = Cms::Layout.where(:identifier => 'default').first
      assert_equal 'Default Fixture Layout', layout.label
      assert_equal "<html>\n  <body>\n    {{ cms:page:content }}\n  </body>\n</html>", layout.content
      assert_equal 'body{color: red}', layout.css
      assert_equal '// default js', layout.js
      
      assert nested_layout = Cms::Layout.where(:identifier => 'nested').first
      assert_equal layout, nested_layout.parent
      assert_equal 'Default Fixture Nested Layout', nested_layout.label
      assert_equal "<div class='left'> {{ cms:page:left }} </div>\n<div class='right'> {{ cms:page:right }} </div>", nested_layout.content
      assert_equal 'div{float:left}', nested_layout.css
      assert_equal '// nested js', nested_layout.js
    end
  end
  
  def test_update
    layout        = cms_layouts(:default)
    nested_layout = cms_layouts(:nested)
    child_layout  = cms_layouts(:child)
    layout.update_column(:updated_at, 10.years.ago)
    nested_layout.update_column(:updated_at, 10.years.ago)
    child_layout.update_column(:updated_at, 10.years.ago)
    
    assert_difference 'Cms::Layout.count', -1 do
      ComfortableMexicanSofa::Fixture::Layout::Importer.new('sample-site', 'default-site').import!
      
      layout.reload
      assert_equal 'Default Fixture Layout', layout.label
      assert_equal "<html>\n  <body>\n    {{ cms:page:content }}\n  </body>\n</html>", layout.content
      assert_equal 'body{color: red}', layout.css
      assert_equal '// default js', layout.js
      assert_equal 0, layout.position
      
      nested_layout.reload
      assert_equal layout, nested_layout.parent
      assert_equal 'Default Fixture Nested Layout', nested_layout.label
      assert_equal "<div class='left'> {{ cms:page:left }} </div>\n<div class='right'> {{ cms:page:right }} </div>", nested_layout.content
      assert_equal 'div{float:left}', nested_layout.css
      assert_equal '// nested js', nested_layout.js
      assert_equal 42, nested_layout.position
      
      assert_nil Cms::Layout.where(:identifier => 'child').first
    end
  end
  
  def test_update_ignore
    layout = cms_layouts(:default)
    layout_path       = File.join(ComfortableMexicanSofa.config.fixtures_path, 'sample-site', 'layouts', 'default')
    attr_file_path    = File.join(layout_path, 'attributes.yml')
    content_file_path = File.join(layout_path, 'content.html')
    css_file_path     = File.join(layout_path, 'stylesheet.css')
    js_file_path      = File.join(layout_path, 'javascript.js')
    
    assert layout.updated_at >= File.mtime(attr_file_path)
    assert layout.updated_at >= File.mtime(content_file_path)
    assert layout.updated_at >= File.mtime(css_file_path)
    assert layout.updated_at >= File.mtime(js_file_path)
    
    ComfortableMexicanSofa::Fixture::Layout::Importer.new('sample-site', 'default-site').import!
    layout.reload
    assert_equal 'default', layout.identifier
    assert_equal 'Default Layout', layout.label
    assert_equal "{{cms:field:default_field_text:text}}\nlayout_content_a\n{{cms:page:default_page_text:text}}\nlayout_content_b\n{{cms:snippet:default}}\nlayout_content_c", layout.content
    assert_equal 'default_css', layout.css
    assert_equal 'default_js', layout.js
  end
  
  def test_update_force
    layout = cms_layouts(:default)
    ComfortableMexicanSofa::Fixture::Layout::Importer.new('sample-site', 'default-site').import!
    layout.reload
    assert_equal 'Default Layout', layout.label
    
    ComfortableMexicanSofa::Fixture::Layout::Importer.new('sample-site', 'default-site', :forced).import!
    layout.reload
    assert_equal 'Default Fixture Layout', layout.label
  end
  
  def test_export
    host_path = File.join(ComfortableMexicanSofa.config.fixtures_path, 'test-site')
    layout_1_attr_path    = File.join(host_path, 'layouts/nested/attributes.yml')
    layout_1_content_path = File.join(host_path, 'layouts/nested/content.html')
    layout_1_css_path     = File.join(host_path, 'layouts/nested/stylesheet.css')
    layout_1_js_path      = File.join(host_path, 'layouts/nested/javascript.js')
    layout_2_attr_path    = File.join(host_path, 'layouts/nested/child/attributes.yml')
    layout_2_content_path = File.join(host_path, 'layouts/nested/child/content.html')
    layout_2_css_path     = File.join(host_path, 'layouts/nested/child/stylesheet.css')
    layout_2_js_path      = File.join(host_path, 'layouts/nested/child/javascript.js')
    
    ComfortableMexicanSofa::Fixture::Layout::Exporter.new('default-site', 'test-site').export!
    
    assert File.exists?(layout_1_attr_path)
    assert File.exists?(layout_1_content_path)
    assert File.exists?(layout_1_css_path)
    assert File.exists?(layout_1_js_path)
    
    assert File.exists?(layout_2_attr_path)
    assert File.exists?(layout_2_content_path)
    assert File.exists?(layout_2_css_path)
    assert File.exists?(layout_2_js_path)
    
    assert_equal ({
      'label'       => 'Nested Layout',
      'app_layout'  => nil,
      'position'    => 0
    }), YAML.load_file(layout_1_attr_path)
    assert_equal cms_layouts(:nested).content, IO.read(layout_1_content_path)
    assert_equal cms_layouts(:nested).css, IO.read(layout_1_css_path)
    assert_equal cms_layouts(:nested).js, IO.read(layout_1_js_path)
    
    assert_equal ({
      'label'       => 'Child Layout',
      'app_layout'  => nil,
      'position'    => 0
    }), YAML.load_file(layout_2_attr_path)
    assert_equal cms_layouts(:child).content, IO.read(layout_2_content_path)
    assert_equal cms_layouts(:child).css, IO.read(layout_2_css_path)
    assert_equal cms_layouts(:child).js, IO.read(layout_2_js_path)
    
    FileUtils.rm_rf(host_path)
  end
  
end
