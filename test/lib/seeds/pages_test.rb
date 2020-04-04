# frozen_string_literal: true

require_relative "../../test_helper"

class SeedsPagesTest < ActiveSupport::TestCase

  setup do
    @site   = comfy_cms_sites(:default)
    @layout = comfy_cms_layouts(:default)
    @page   = comfy_cms_pages(:default)
  end

  def test_creation
    Comfy::Cms::Page.delete_all

    assert_difference -> { Comfy::Cms::Page.count }, 3 do
      assert_difference -> { Comfy::Cms::Translation.count }, 2 do
        ComfortableMexicanSofa::Seeds::Page::Importer.new("sample-site", "default-site").import!
      end
    end

    assert page = Comfy::Cms::Page.find_by(full_path: "/")

    assert_equal @layout, page.layout
    assert_equal "index", page.slug

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
        boolean:    false }
    ], page.fragments_attributes

    frag = page.fragments.find_by(identifier: "header")
    assert_equal 1, frag.attachments.count

    frag = page.fragments.find_by(identifier: "attachments")
    assert_equal 3, frag.attachments.count

    assert_equal 2, page.categories.count
    assert_equal %w[category_a category_b], page.categories.map(&:label)

    assert child_page_a = Comfy::Cms::Page.find_by(full_path: "/child_a")
    assert_equal page, child_page_a.parent

    assert child_page_b = Comfy::Cms::Page.find_by(full_path: "/child_b")
    assert_equal page, child_page_b.parent

    assert_equal child_page_b, child_page_a.target_page

    assert_equal 2, page.translations.count
    translation = page.translations.where(locale: "fr").first

    assert_equal "Bienvenue", translation.label
    assert_equal [
      { identifier: "content",
        tag:        "wysiwyg",
        content:    "French Home Page Seed Content\n",
        datetime:   nil,
        boolean:    false }
    ], translation.fragments_attributes
  end

  def test_update
    @page.update_column(:updated_at, 10.years.ago)
    assert_equal "Default Page", @page.label

    child = comfy_cms_pages(:child)
    child.update_column(:slug, "old")

    assert_difference -> { Comfy::Cms::Page.count } do
      ComfortableMexicanSofa::Seeds::Page::Importer.new("sample-site", "default-site").import!

      @page.reload
      assert_equal "Home Seed Page", @page.label

      assert_nil Comfy::Cms::Page.where(slug: "old").first
    end
  end

  def test_update_ignore
    Comfy::Cms::Page.destroy_all

    page = @site.pages.create!(
      label: "Test",
      layout: comfy_cms_layouts(:default),
      fragments_attributes: [
        { identifier: "content", content: "test content" }
      ]
    )

    page_path         = File.join(ComfortableMexicanSofa.config.seeds_path, "sample-site", "pages", "index")
    content_path      = File.join(page_path, "content.html")

    assert page.updated_at >= File.mtime(content_path)

    ComfortableMexicanSofa::Seeds::Page::Importer.new("sample-site", "default-site").import!
    page.reload

    assert_nil page.slug
    assert_equal "Test", page.label
    frag = page.fragments.where(identifier: "content").first
    assert_equal "test content", frag.content
  end

  def test_update_removing_deleted_blocks
    Comfy::Cms::Page.destroy_all

    page = @site.pages.create!(
      label:  "Test",
      layout: comfy_cms_layouts(:default),
      fragments_attributes: [
        { identifier: "to_delete", content: "test content" }
      ]
    )
    page.update_column(:updated_at, 10.years.ago)

    ComfortableMexicanSofa::Seeds::Page::Importer.new("sample-site", "default-site").import!
    page.reload

    frag = page.fragments.where(identifier: "content").first
    assert_equal "Home Page Seed Contént\n{{ cms:snippet default }}\n\n", frag.content

    refute page.fragments.where(identifier: "to_delete").first
  end

  def test_export
    ActiveStorage::Blob.any_instance.stubs(:download).returns(
      file_fixture("image.jpg").read
    )

    comfy_cms_pages(:default).update_attribute(:target_page, comfy_cms_pages(:child))
    comfy_cms_categories(:default).categorizations.create!(
      categorized: comfy_cms_pages(:default)
    )

    comfy_cms_translations(:default).update!(fragments_attributes: [
      {
        identifier: "content",
        content:    "translation content",
        tag:        "markdown"
      }
    ])

    host_path = File.join(ComfortableMexicanSofa.config.seeds_path, "test-site")
    page_1_content_path     = File.join(host_path, "pages/index/content.html")
    page_1_attachment_path  = File.join(host_path, "pages/index/fragment.jpg")
    page_2_content_path     = File.join(host_path, "pages/index/child-page/content.html")
    translation_path        = File.join(host_path, "pages/index/content.fr.html")

    ComfortableMexicanSofa::Seeds::Page::Exporter.new("default-site", "test-site").export!

    out = <<~TEXT.chomp
      [attributes]
      ---
      label: Default Page
      layout: default
      target_page: "/child-page"
      categories:
      - Default
      is_published: true
      position: 0
      [checkbox boolean]
      true
      [file file]
      fragment.jpg
      [datetime datetime]
      1981-10-04 12:34:56 UTC
      [text content]
      content
    TEXT
    assert_equal out, IO.read(page_1_content_path)

    assert File.exist?(page_1_attachment_path)

    out = <<~TEXT.chomp
      [attributes]
      ---
      label: Child Page
      layout: default
      target_page:\s
      categories: []
      is_published: true
      position: 0

    TEXT
    assert_equal out, IO.read(page_2_content_path)

    out = <<~TEXT.chomp
      [attributes]
      ---
      label: Default Translation
      layout: default
      is_published: true
      [markdown content]
      translation content
    TEXT
    assert_equal out, IO.read(translation_path)

  ensure
    FileUtils.rm_rf(host_path)
  end

end
