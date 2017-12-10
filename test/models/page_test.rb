require_relative "../test_helper"

class CmsPageTest < ActiveSupport::TestCase

  setup do
    @site   = comfy_cms_sites(:default)
    @layout = comfy_cms_layouts(:default)
    @page   = comfy_cms_pages(:default)
  end

  def new_params(options = {})
    { label:  "Test Page",
      slug:   "test-page",
      layout: @layout
    }.merge(options)
  end

  # -- Tests -------------------------------------------------------------------

  def test_fixtures_validity
    Comfy::Cms::Page.all.each do |page|
      assert page.valid?, page.errors.full_messages.to_s
      assert_equal page.content_cache, page.render
    end
  end

  def test_validations
    page = Comfy::Cms::Page.new
    page.save
    assert page.invalid?
    assert_has_errors_on page, :site, :layout, :slug, :label
  end

  def test_validation_of_parent_presence
    page = @site.pages.new(new_params)
    assert !page.parent
    assert page.valid?, page.errors.full_messages.to_s
    assert_equal @page, page.parent
  end

  def test_validation_of_parent_relationship
    assert !@page.parent
    @page.parent = @page
    assert @page.invalid?
    assert_has_errors_on @page, :parent_id

    @page.parent = comfy_cms_pages(:child)
    assert @page.invalid?
    assert_has_errors_on @page, :parent_id
  end

  def test_validation_of_target_page
    page = comfy_cms_pages(:child)
    page.target_page = @page
    page.save!
    assert_equal @page, page.target_page
    page.target_page = page
    assert page.invalid?
    assert_has_errors_on page, :target_page_id
  end

  def test_validation_of_slug
    page = comfy_cms_pages(:child)
    page.slug = "slug.with.d0ts-and_things"
    assert page.valid?

    page.slug = "inva lid"
    assert page.invalid?

    page.slug = "acción"
    assert page.valid?
  end

  def test_validation_of_slug_allows_unicode_accent_characters
    page = comfy_cms_pages(:child)
    thai_character_ko_kai   = "\u0e01"
    thai_character_mai_tho  = "\u0E49"
    page.slug = thai_character_ko_kai + thai_character_mai_tho
    assert page.valid?
  end

  def test_label_assignment
    page = @site.pages.new(
      slug:   "test",
      parent: @page,
      layout: @layout
    )
    assert page.valid?
    assert_equal "Test", page.label
  end

  def test_create
    assert_count_difference [Comfy::Cms::Page, Comfy::Cms::Fragment] do
      page = @site.pages.create!(
        new_params(
          parent: @page,
          fragments_attributes: [
            { identifier: "content",
              tag:        "text",
              content:    "test" }
          ]
        )
      )
      assert page.is_published?
      assert_equal 1, page.position
    end
  end

  def test_create_with_file
    assert_count_difference [Comfy::Cms::Page, Comfy::Cms::Fragment, ActiveStorage::Attachment] do
      page = @site.pages.create!(
        new_params(
          parent: @page,
          fragments_attributes: [{
            identifier: "test",
            tag:        "file",
            files:      [fixture_file_upload("files/image.jpg", "image/jpeg")]
          }]
        )
      )
      assert_equal 1, page.fragments.count
      assert page.fragments.first.attachments.attached?
    end
  end

  def test_create_with_files
    assert_count_difference [Comfy::Cms::Page, Comfy::Cms::Fragment] do
      assert_count_difference [ActiveStorage::Attachment], 2 do
        page = @site.pages.create!(
          new_params(
            parent: @page,
            fragments_attributes: [{
              identifier: "test",
              tag:        "files",
              files:      [
                fixture_file_upload("files/image.jpg", "image/jpeg"),
                fixture_file_upload("files/document.pdf", "application/pdf")
              ]
            }]
          )
        )
        assert_equal 1, page.fragments.count
        assert page.fragments.first.attachments.attached?
      end
    end
  end

  def test_create_with_date
    string = "1981-10-04 12:34:56"
    datetime = DateTime.parse(string)
    assert_count_difference [Comfy::Cms::Page, Comfy::Cms::Fragment] do
      page = @site.pages.create!(
        new_params(
          parent: @page,
          fragments_attributes: [{
            identifier: "test",
            tag:        "date_time",
            datetime:   string
          }]
        )
      )
      frag = page.fragments.first
      assert_equal datetime, frag.datetime
    end
  end

  def test_create_with_boolean
    assert_count_difference [Comfy::Cms::Page, Comfy::Cms::Fragment] do
      page = @site.pages.create!(
        new_params(
          parent: @page,
          fragments_attributes: [{
            identifier: "test",
            tag:        "checkbox",
            boolean:    "1"
          }]
        )
      )
      frag = page.fragments.first
      assert frag.boolean
    end
  end

  def test_update
    frag = comfy_cms_fragments(:default)
    assert_count_no_difference [Comfy::Cms::Page, Comfy::Cms::Fragment] do
      @page.update_attributes!(fragments_attributes: [
        { identifier: frag.identifier,
          content:    "updated content" }
      ])
    end
    frag.reload
    assert_equal "updated content", frag.content
  end

  def test_update_with_file
    assert_count_no_difference [ActiveStorage::Attachment] do
      @page.update_attributes!(
        fragments_attributes: [{
          identifier: "file",
          tag:        "file",
          files:      fixture_file_upload("files/document.pdf", "application/pdf")
        }]
      )
      assert_equal "document.pdf", comfy_cms_fragments(:file).attachments.first.filename.to_s
    end
  end

  def test_update_with_file_removal
    id = comfy_cms_fragments(:file).attachments.first.id
    assert_count_difference [ActiveStorage::Attachment], -1 do
      @page.update_attributes!(
        fragments_attributes: [{
          identifier:       "file",
          file_ids_destroy: [id]
        }]
      )
    end
  end

  def test_update_with_date
    frag = comfy_cms_fragments(:datetime)
    string = "2020-01-01"
    date = DateTime.parse(string)
    assert_count_no_difference [Comfy::Cms::Page, Comfy::Cms::Fragment] do
      @page.update_attributes!(fragments_attributes: [
        { identifier: frag.identifier,
          datetime:   string }
      ])
    end
    frag.reload
    assert_equal date, frag.datetime
  end

  def test_update_with_boolean
    frag = comfy_cms_fragments(:boolean)
    assert frag.boolean
    assert_count_no_difference [Comfy::Cms::Page, Comfy::Cms::Fragment] do
      @page.update_attributes!(fragments_attributes: [
        { identifier: frag.identifier,
          boolean:    "0" }
      ])
    end
    frag.reload
    refute frag.boolean
  end

  def test_update_with_parent_id_change
    page_a = @page
    page_b = comfy_cms_pages(:child)
    page_c = @site.pages.create!(
      label:  "Test Page",
      slug:   "test-page",
      layout: @layout,
      parent: page_a
    )

    assert_equal 2, page_a.children_count
    assert_equal 0, page_b.children_count
    assert_equal 0, page_c.children_count

    page_c.update_attributes!(parent_id: page_b)

    [page_a, page_b, page_c].each(&:reload)
    assert_equal 1, page_a.children_count
    assert_equal 1, page_b.children_count
    assert_equal 0, page_c.children_count
  end

  def test_initialization_of_full_path
    page = Comfy::Cms::Page.new
    assert_equal "/", page.full_path

    page = Comfy::Cms::Page.new(new_params)
    assert page.invalid?
    assert_has_errors_on page, :site

    page = @site.pages.new(new_params(parent: @page))
    assert page.valid?
    assert_equal "/test-page", page.full_path

    page = @site.pages.new(new_params(parent: comfy_cms_pages(:child)))
    assert page.valid?
    assert_equal "/child-page/test-page", page.full_path

    Comfy::Cms::Page.destroy_all
    page = @site.pages.new(new_params)
    assert page.valid?
    assert_equal "/", page.full_path
  end

  def test_sync_child_pages
    page = comfy_cms_pages(:child)
    page_a = @site.pages.create!(new_params(parent: page, slug: "test-page-1"))
    page_b = @site.pages.create!(new_params(parent: page, slug: "test-page-2"))
    page_c = @site.pages.create!(new_params(parent: page_b, slug: "test-page-3"))
    page_d = @site.pages.create!(new_params(parent: page_a, slug: "test-page-4"))

    assert_equal "/child-page/test-page-1", page_a.full_path
    assert_equal "/child-page/test-page-2", page_b.full_path
    assert_equal "/child-page/test-page-2/test-page-3", page_c.full_path
    assert_equal "/child-page/test-page-1/test-page-4", page_d.full_path

    page.update_attributes!(slug: "updated-page")
    assert_equal "/updated-page", page.full_path
    [page_a, page_b, page_c, page_d].each(&:reload)
    assert_equal "/updated-page/test-page-1", page_a.full_path
    assert_equal "/updated-page/test-page-2", page_b.full_path
    assert_equal "/updated-page/test-page-2/test-page-3", page_c.full_path
    assert_equal "/updated-page/test-page-1/test-page-4", page_d.full_path

    page_b.update_attributes!(parent: page_a)
    [page_a, page_b, page_c, page_d].each(&:reload)
    assert_equal "/updated-page/test-page-1", page_a.full_path
    assert_equal "/updated-page/test-page-1/test-page-2", page_b.full_path
    assert_equal "/updated-page/test-page-1/test-page-2/test-page-3", page_c.full_path
    assert_equal "/updated-page/test-page-1/test-page-4", page_d.full_path
  end

  def test_children_count_updating
    page_a = @page
    page_b = comfy_cms_pages(:child)
    assert_equal 1, page_a.children_count
    assert_equal 0, page_b.children_count

    page_c = @site.pages.create!(new_params(parent: page_b))
    [page_a, page_b].each(&:reload)
    assert_equal 1, page_a.children_count
    assert_equal 1, page_b.children_count
    assert_equal 0, page_c.children_count

    page_c.update_attributes!(parent: page_a)
    [page_a, page_b].each(&:reload)
    assert_equal 2, page_a.children_count
    assert_equal 0, page_b.children_count

    page_c.destroy
    [page_a, page_b].each(&:reload)
    assert_equal 1, page_a.children_count
    assert_equal 0, page_b.children_count
  end

  def test_cascading_destroy
    assert_count_difference [Comfy::Cms::Page], -2 do
      assert_count_difference [Comfy::Cms::Fragment], -4 do
        assert_count_difference [Comfy::Cms::Translation], -1 do
          @page.destroy
        end
      end
    end
  end

  def test_options_for_select
    assert_equal ["Default Page", ". . Child Page"],
      Comfy::Cms::Page.options_for_select(site: @site).collect(&:first)
    assert_equal ["Default Page"],
      Comfy::Cms::Page.options_for_select(site: @site, page: comfy_cms_pages(:child)).collect(&:first)
    assert_equal [],
      Comfy::Cms::Page.options_for_select(site: @site, page: @page)

    page = Comfy::Cms::Page.new(new_params(parent: @page))
    assert_equal ["Default Page", ". . Child Page"],
      Comfy::Cms::Page.options_for_select(site: @site, page: page).collect(&:first)
  end

  def test_fragments_attributes
    assert_equal @page.fragments.count, @page.fragments_attributes.size

    @page.fragments_attributes = [
      { identifier: "content",
        content:    "updated content"
      }
    ]

    assert_equal [
      { identifier: "boolean",
        tag:        "checkbox",
        content:    nil,
        datetime:   nil,
        boolean:    true },
      { identifier: "file",
        tag:        "file",
        content:    nil,
        datetime:   nil,
        boolean:    false },
      { identifier: "datetime",
        tag:        "datetime",
        content:    nil,
        datetime:   comfy_cms_fragments(:datetime).datetime,
        boolean:    false },
      { identifier: "content",
        tag:        "text",
        content:    "updated content",
        datetime:   nil,
        boolean:    false }
    ], @page.fragments_attributes

    assert_equal [
      { identifier: "boolean",
        tag:        "checkbox",
        content:    nil,
        datetime:   nil,
        boolean:    true },
      { identifier: "file",
        tag:        "file",
        content:    nil,
        datetime:   nil,
        boolean:    false },
      { identifier: "datetime",
        tag:        "datetime",
        content:    nil,
        datetime:   comfy_cms_fragments(:datetime).datetime,
        boolean:    false },
      { identifier: "content",
        tag:        "text",
        content:    "content",
        datetime:   nil,
        boolean:    false }
    ], @page.fragments_attributes_was
  end

  def test_render
    expected = @page.render
    assert_equal "content", expected
  end

  def test_fragment_nodes
    content = "a {{cms:text a}} b {{cms:snippet b}} c {{cms:text c}}"
    @page.layout.update_column(:content, content)
    nodes = @page.fragment_nodes
    assert_equal 2, nodes.count
    assert_equal "a", nodes[0].identifier
    assert_equal "c", nodes[1].identifier
  end

  def test_fragment_nodes_with_duplicates
    content = "{{cms:wysiwyg test}} {{cms:markdown test}}"
    @page.layout.update_column(:content, content)
    nodes = @page.fragment_nodes
    assert_equal 1, nodes.count
    assert_equal ComfortableMexicanSofa::Content::Tag::Wysiwyg, nodes[0].class
    assert_equal "test", nodes[0].identifier
  end

  def test_fragment_nodes_with_no_layout
    @page.update_column(:layout_id, nil)
    assert_equal [], @page.fragment_nodes
  end

  def test_content_caching
    assert_equal @page.content_cache, @page.render

    @page.update_columns(content_cache: "Old Content")
    refute_equal @page.content_cache, @page.render

    @page.clear_content_cache!
    assert_equal @page.content_cache, @page.render
  end

  def test_content_cache_clear_on_save
    old_content = "Old Content"
    @page.update_columns(content_cache: old_content)

    @page.save!
    refute_equal old_content, @page.content_cache
  end

  def test_scope_published
    assert_equal 2, Comfy::Cms::Page.published.count
    comfy_cms_pages(:child).update_columns(is_published: false)
    assert_equal 1, Comfy::Cms::Page.published.count
  end

  def test_root?
    assert @page.root?
    refute comfy_cms_pages(:child).root?
  end

  def test_url
    assert_equal "//test.host/", @page.url
    assert_equal "//test.host/child-page", comfy_cms_pages(:child).url

    assert_equal "/", @page.url(relative: true)
    assert_equal "/child-page", comfy_cms_pages(:child).url(relative: true)

    @site.update_columns(path: "/en/site")
    @page.reload
    comfy_cms_pages(:child).reload

    assert_equal "//test.host/en/site/", @page.url
    assert_equal "//test.host/en/site/child-page", comfy_cms_pages(:child).url

    assert_equal "/en/site/", @page.url(relative: true)
    assert_equal "/en/site/child-page", comfy_cms_pages(:child).url(relative: true)
  end

  def test_url_with_public_cms_path
    ComfortableMexicanSofa.config.public_cms_path = "/custom"
    assert_equal "//test.host/custom/", @page.url
    assert_equal "//test.host/custom/child-page", comfy_cms_pages(:child).url

    assert_equal "/custom/", @page.url(relative: true)
    assert_equal "/custom/child-page", comfy_cms_pages(:child).url(relative: true)
  end

  def test_unicode_slug_escaping
    page = comfy_cms_pages(:child)
    page_a = @site.pages.create!(new_params(parent: page, slug: "tést-ünicode-slug"))
    assert_equal CGI.escape("tést-ünicode-slug"), page_a.slug
    assert_equal CGI.escape("/child-page/tést-ünicode-slug").gsub("%2F", "/"), page_a.full_path
  end

  def test_unicode_slug_unescaping
    page = comfy_cms_pages(:child)
    @site.pages.create!(new_params(parent: page, slug: "tést-ünicode-slug"))
    found_page = @site.pages.where(slug: CGI.escape("tést-ünicode-slug")).first
    assert_equal "tést-ünicode-slug", found_page.slug
    assert_equal "/child-page/tést-ünicode-slug", found_page.full_path
  end

  def test_identifier
    assert_equal "index",       @page.identifier
    assert_equal "child-page",  comfy_cms_pages(:child).identifier

    @page.update_column(:slug, "index")
    assert_equal "index", comfy_cms_pages(:default).identifier
  end

  def test_children_count_updating_on_move
    page_a = @page
    page_b = comfy_cms_pages(:child)
    page_c = @site.pages.create!(new_params(parent: page_b))

    page_b.reload

    assert_equal 1, page_a.children_count
    assert_equal 1, page_b.children_count
    assert_equal 0, page_c.children_count

    page_c.parent_id = page_a.id
    page_c.save!

    [page_a, page_b, page_c].each(&:reload)

    assert_equal 2, page_a.children_count
    assert_equal 0, page_b.children_count
    assert_equal 0, page_c.children_count
  end

  def test_translate
    translation = comfy_cms_translations(:default)
    translation.update_columns(layout_id: comfy_cms_layouts(:nested).id)

    @page.translate!(:fr)
    assert @page.readonly?

    assert_equal comfy_cms_layouts(:nested), @page.layout
    assert_equal "Default Translation", @page.label
    assert_equal "Translation Content", @page.content_cache
  end

  def test_translate_with_unpublished
    comfy_cms_translations(:default).update_column(:is_published, false)
    assert_exception_raised ActiveRecord::RecordNotFound do
      @page.translate!(:fr)
    end
  end

  def test_translate_with_invalid_locale
    assert_exception_raised ActiveRecord::RecordNotFound do
      @page.translate!(:es)
    end
  end

end
