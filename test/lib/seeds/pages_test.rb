require_relative '../../test_helper'

require 'mimemagic'

class SeedsPagesTest < ActiveSupport::TestCase

  setup do
    @site   = comfy_cms_sites(:default)
    @layout = comfy_cms_layouts(:default)
  end

  def test_creation
    Comfy::Cms::Page.delete_all

    site = comfy_cms_sites(:default)

    assert_count_difference "Comfy::Cms::Page", 3 do
      ComfortableMexicanSofa::Seeds::Page::Importer.new('sample-site', 'default-site').import!
    end

    assert page = Comfy::Cms::Page.find_by(full_path: "/")

    assert_equal @layout, page.layout
    assert_equal 'index', page.slug

    assert_equal "Home Seed Page", page.label
    assert_equal 69, page.position
    assert page.is_published?

    assert_equal 5, page.fragments.count
    assert_equal [
      { identifier: "header",
        tag:        "file",
        content:    nil,
        datetime:   nil,
        boolean:    false },
      { identifier: "published_on",
        tag:        "date",
        content:    nil,
        datetime:   Date.parse("2015-10-31"),
        boolean:    false },
      { identifier: "content",
        tag:        "wysiwyg",
        content:    "Home Page Seed Contént\n{{ cms:snippet default }}\n\n",
        datetime:   nil,
        boolean:    false },
      { identifier: "published",
        tag:        "checkbox",
        content:    nil,
        datetime:   nil,
        boolean:    true },
      { identifier: "attachments",
        tag:        "files",
        content:    nil,
        datetime:   nil,
        boolean:    false}
    ], page.fragments_attributes

    frag = page.fragments.find_by(identifier: "header")
    assert_equal 1, frag.attachments.count

    frag = page.fragments.find_by(identifier: "attachments")
    assert_equal 2, frag.attachments.count

    assert_equal 2, page.categories.count
    assert_equal %w(category_a category_b), page.categories.map{|c| c.label}

    assert child_page = Comfy::Cms::Page.find_by(full_path: "/child_a")
    assert_equal page, child_page.parent

    assert child_page = Comfy::Cms::Page.find_by(full_path: "/child_b")
    assert_equal page, child_page.parent
  end


  def test_update
    page = comfy_cms_pages(:default)
    page.update_column(:updated_at, 10.years.ago)
    assert_equal "Default Page", page.label

    child = comfy_cms_pages(:child)
    child.update_column(:slug, 'old')

    assert_count_difference [Comfy::Cms::Page] do
      ComfortableMexicanSofa::Seeds::Page::Importer.new('sample-site', 'default-site').import!

      page.reload
      assert_equal "Home Seed Page", page.label

      assert_nil Comfy::Cms::Page.where(slug: 'old').first
    end
  end

  def test_update_ignore
    Comfy::Cms::Page.destroy_all

    page = @site.pages.create!(
      label: 'Test',
      layout: comfy_cms_layouts(:default),
      fragments_attributes: [
        { identifier: "content", content: "test content" }
      ]
    )

    page_path         = File.join(ComfortableMexicanSofa.config.seeds_path, 'sample-site', 'pages', 'index')
    content_path      = File.join(page_path, "content.html")

    assert page.updated_at >= File.mtime(content_path)

    ComfortableMexicanSofa::Seeds::Page::Importer.new('sample-site', 'default-site').import!
    page.reload

    assert_nil page.slug
    assert_equal 'Test', page.label
    frag = page.fragments.where(identifier: "content").first
    assert_equal 'test content', frag.content
  end

  def test_update_removing_deleted_blocks
    Comfy::Cms::Page.destroy_all

    page = @site.pages.create!(
      label:  'Test',
      layout: comfy_cms_layouts(:default),
      fragments_attributes: [
        { identifier: 'to_delete', content: 'test content' }
      ]
    )
    page.update_column(:updated_at, 10.years.ago)

    ComfortableMexicanSofa::Seeds::Page::Importer.new('sample-site', 'default-site').import!
    page.reload

    frag = page.fragments.where(identifier: 'content').first
    assert_equal "Home Page Seed Contént\n{{ cms:snippet default }}\n\n", frag.content

    refute page.fragments.where(identifier: 'to_delete').first
  end




  def test_export
    comfy_cms_pages(:default).update_attribute(:target_page, comfy_cms_pages(:child))
    comfy_cms_categories(:default).categorizations.create!(
      categorized: comfy_cms_pages(:default)
    )

    host_path = File.join(ComfortableMexicanSofa.config.seeds_path, 'test-site')
    page_1_attr_path = File.join(host_path, 'pages/index/attributes.yml')
    page_1_frag_path = File.join(host_path, 'pages/index/content.html')
    page_2_attr_path = File.join(host_path, 'pages/index/child-page/attributes.yml')

    ComfortableMexicanSofa::Seeds::Page::Exporter.new('default-site', 'test-site').export!

    assert_equal ({
      'label'         => 'Default Page',
      'layout'        => 'default',
      'parent'        => nil,
      'target_page'   => '/child-page',
      'categories'    => ['Default'],
      'is_published'  => true,
      'position'      => 0
    }), YAML.load_file(page_1_attr_path)
    assert_equal comfy_cms_fragments(:default).content, IO.read(page_1_frag_path)

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
