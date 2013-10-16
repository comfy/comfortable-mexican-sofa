# encoding: utf-8

require_relative '../../test_helper'

class FixturePagesTest < ActiveSupport::TestCase
  
  def test_creation
    Cms::Page.delete_all
    
    layout = cms_layouts(:default)
    layout.update_column(:content, '<html>{{cms:page:content}}</html>')
    
    nested = cms_layouts(:nested)
    nested.update_column(:content, '<html>{{cms:page:left}}<br/>{{cms:page:right}}</html>')
    
    assert_difference 'Cms::Page.count', 2 do
      ComfortableMexicanSofa::Fixture::Page::Importer.new('sample-site', 'default-site').import!
      
      assert page = Cms::Page.where(:full_path => '/').first
      assert_equal layout, page.layout
      assert_equal 'index', page.slug
      assert_equal "<html>Home Page Fixture Contént\ndefault_snippet_content</html>", page.content
      assert_equal 0, page.position
      assert page.is_published?
      assert_equal 2, page.categories.count
      assert_equal ['category_a', 'category_b'], page.categories.map{|c| c.label}
      
      assert child_page = Cms::Page.where(:full_path => '/child').first
      assert_equal page, child_page.parent
      assert_equal nested, child_page.layout
      assert_equal 'child', child_page.slug
      assert_equal '<html>Child Page Left Fixture Content<br/>Child Page Right Fixture Content</html>', child_page.content
      assert_equal 42, child_page.position
      
      assert_equal child_page, page.target_page
    end
  end
  
  def test_update
    page = cms_pages(:default)
    page.update_column(:updated_at, 10.years.ago)
    assert_equal 'Default Page', page.label
    
    child = cms_pages(:child)
    child.update_column(:slug, 'old')
    
    assert_no_difference 'Cms::Page.count' do
      ComfortableMexicanSofa::Fixture::Page::Importer.new('sample-site', 'default-site').import!
      
      page.reload
      assert_equal 'Home Fixture Page', page.label
      
      assert_nil Cms::Page.where(:slug => 'old').first
    end
  end
  
  def test_update_ignore
    Cms::Page.destroy_all
    
    page = cms_sites(:default).pages.create!(
      :label  => 'Test',
      :layout => cms_layouts(:default),
      :blocks_attributes => [ { :identifier => 'content', :content => 'test content' } ]
    )
    
    page_path         = File.join(ComfortableMexicanSofa.config.fixtures_path, 'sample-site', 'pages', 'index')
    attr_file_path    = File.join(page_path, 'attributes.yml')
    content_file_path = File.join(page_path, 'content.html')
    
    assert page.updated_at >= File.mtime(attr_file_path)
    assert page.updated_at >= File.mtime(content_file_path)
    
    ComfortableMexicanSofa::Fixture::Page::Importer.new('sample-site', 'default-site').import!
    page.reload
    
    assert_equal nil, page.slug
    assert_equal 'Test', page.label
    block = page.blocks.where(:identifier => 'content').first
    assert_equal 'test content', block.content
  end
  
  def test_update_force
    page = cms_pages(:default)
    ComfortableMexicanSofa::Fixture::Page::Importer.new('sample-site', 'default-site').import!
    page.reload
    assert_equal 'Default Page', page.label
    
    ComfortableMexicanSofa::Fixture::Page::Importer.new('sample-site', 'default-site', :forced).import!
    page.reload
    assert_equal 'Home Fixture Page', page.label
  end
  
  def test_update_removing_deleted_blocks
    Cms::Page.destroy_all
    
    page = cms_sites(:default).pages.create!(
      :label  => 'Test',
      :layout => cms_layouts(:default),
      :blocks_attributes => [ { :identifier => 'to_delete', :content => 'test content' } ]
    )
    page.update_column(:updated_at, 10.years.ago)
    
    ComfortableMexicanSofa::Fixture::Page::Importer.new('sample-site', 'default-site').import!
    page.reload
    
    block = page.blocks.where(:identifier => 'content').first
    assert_equal "Home Page Fixture Contént\n{{ cms:snippet:default }}", block.content
    
    assert !page.blocks.where(:identifier => 'to_delete').first
  end
  
  def test_export
    cms_pages(:default).update_attribute(:target_page, cms_pages(:child))
    cms_categories(:default).categorizations.create!(
      :categorized => cms_pages(:default)
    )
    
    host_path = File.join(ComfortableMexicanSofa.config.fixtures_path, 'test-site')
    page_1_attr_path    = File.join(host_path, 'pages/index/attributes.yml')
    page_1_block_a_path = File.join(host_path, 'pages/index/default_field_text.html')
    page_1_block_b_path = File.join(host_path, 'pages/index/default_page_text.html')
    page_2_attr_path    = File.join(host_path, 'pages/index/child-page/attributes.yml')
    
    ComfortableMexicanSofa::Fixture::Page::Exporter.new('default-site', 'test-site').export!
    
    assert_equal ({
      'label'         => 'Default Page',
      'layout'        => 'default',
      'parent'        => nil,
      'target_page'   => '/child-page',
      'categories'    => ['Default'],
      'is_published'  => true,
      'position'      => 0
    }), YAML.load_file(page_1_attr_path)
    assert_equal cms_blocks(:default_field_text).content, IO.read(page_1_block_a_path)
    assert_equal cms_blocks(:default_page_text).content, IO.read(page_1_block_b_path)
    
    assert_equal ({
      'label'         => 'Child Page',
      'layout'        => 'default',
      'parent'        => 'index',
      'target_page'   => nil,
      'categories'    => [],
      'is_published'  => true,
      'position'      => 0
    }), YAML.load_file(page_2_attr_path)
    
    FileUtils.rm_rf(host_path)
  end
  
end
