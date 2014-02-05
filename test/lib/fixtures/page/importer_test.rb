# encoding: utf-8
require_relative '../../../test_helper'

class FixturePagesImporterTest < ActiveSupport::TestCase
  def test_single_page_create_with_missing_parent
    Cms::Page.destroy_all
    assert_no_difference 'Cms::Page.count',
      "A child should not be created when it's parent doesn't exist" do

      assert_nil importer.import_only! 'index/child'
    end
  end

  def test_single_page_create
    Cms::Page.delete_all
    # should not regenerate child node.
    assert_difference 'Cms::Page.count', 1 do
      page = importer.import_only! 'index'
      assert_equal 'Home Fixture Page', page.label
      assert_equal 'index', page.slug
    end
  end
  def test_single_page_create_child_page_with_non_fixture_pages
    cms_sites(:default).pages.create!(
      slug: 'non-fixture-page',
      label: 'should not be removed',
      layout: cms_layouts(:default)
    )

    assert_difference 'Cms::Page.count', 1 do
      page = importer.import_only! 'index/child'
      assert_equal 'child', page.slug
      assert_equal 'Child Fixture Page', page.label
      assert_equal Cms::Page.root, page.parent
    end
  end

  def test_single_page_update_no_force
    existing_page = cms_pages :default
    page = importer.import_only! 'index'

    assert_no_difference 'Cms::Page.count' do
      assert_equal existing_page, page
      assert_equal 'Default Page', page.label
    end
  end

  def test_single_page_update_with_force
    page = cms_pages :default
    assert_no_difference 'Cms::Page.count' do
      importer(true).import_only! 'index'
      page.reload
      assert_equal 'Home Fixture Page', page.label
      assert page.children.include? cms_pages(:child)
      assert_equal cms_pages(:child).parent, page
    end
  end

  def test_creation
    Cms::Page.delete_all

    layout = cms_layouts(:default)
    layout.update_column(:content, '<html>{{cms:page:content}}</html>')

    nested = cms_layouts(:nested)
    nested.update_column(:content, '<html>{{cms:page:left}}<br/>{{cms:page:right}}</html>')

    assert_difference 'Cms::Page.count', 2 do
      importer.import!

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
      importer.import!

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

    importer.import!
    page.reload

    assert_nil page.slug
    assert_equal 'Test', page.label
    block = page.blocks.where(:identifier => 'content').first
    assert_equal 'test content', block.content
  end

  def test_update_force
    page = cms_pages(:default)
    importer.import!
    page.reload
    assert_equal 'Default Page', page.label
    importer(:forced).import!
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

    importer.import!
    page.reload

    block = page.blocks.where(:identifier => 'content').first
    assert_equal "Home Page Fixture Contént\n{{ cms:snippet:default }}", block.content

    assert !page.blocks.where(:identifier => 'to_delete').first
  end

  private
  def importer *args
    ComfortableMexicanSofa::Fixture::Page::Importer.new('sample-site', 'default-site', *args)
  end
end
