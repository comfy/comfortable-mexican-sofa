# frozen_string_literal: true

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

    page_c.update!(parent_id: page_b)

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

    page.update!(slug: "updated-page")
    assert_equal "/updated-page", page.full_path
    [page_a, page_b, page_c, page_d].each(&:reload)
    assert_equal "/updated-page/test-page-1", page_a.full_path
    assert_equal "/updated-page/test-page-2", page_b.full_path
    assert_equal "/updated-page/test-page-2/test-page-3", page_c.full_path
    assert_equal "/updated-page/test-page-1/test-page-4", page_d.full_path

    page_b.update!(parent: page_a)
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

    page_c.update!(parent: page_a)
    [page_a, page_b].each(&:reload)
    assert_equal 2, page_a.children_count
    assert_equal 0, page_b.children_count

    page_c.destroy
    [page_a, page_b].each(&:reload)
    assert_equal 1, page_a.children_count
    assert_equal 0, page_b.children_count
  end

  def test_cascading_destroy
    assert_difference(-> { Comfy::Cms::Page.count }, -2) do
      assert_difference(-> { Comfy::Cms::Fragment.count }, -5) do
        assert_difference(-> { Comfy::Cms::Translation.count }, -1) do
          @page.destroy
        end
      end
    end
  end

  def test_options_for_select
    options = ["Default Page", ". . Child Page"]
    assert_equal options, Comfy::Cms::Page.options_for_select(site: @site).map(&:first)

    expected = ["Default Page"]
    actual = Comfy::Cms::Page.options_for_select(
      site:         @site,
      current_page: comfy_cms_pages(:child),
      exclude_self: true
    ).map(&:first)
    assert_equal expected, actual

    Comfy::Cms::Page.delete_all
    assert_equal [], Comfy::Cms::Page.options_for_select(site: @site).map(&:first)
  end







  def test_scope_published
    assert_equal 2, Comfy::Cms::Page.published.count
    comfy_cms_pages(:child).update_columns(is_published: false)
    assert_equal 1, Comfy::Cms::Page.published.count
  end


  def test_url
    assert_equal "//www.example.com/", @page.url
    assert_equal "//www.example.com/child-page", comfy_cms_pages(:child).url

    assert_equal "/", @page.url(relative: true)
    assert_equal "/child-page", comfy_cms_pages(:child).url(relative: true)

    @site.update_columns(path: "/en/site")
    @page.reload
    comfy_cms_pages(:child).reload

    assert_equal "//www.example.com/en/site/", @page.url
    assert_equal "//www.example.com/en/site/child-page", comfy_cms_pages(:child).url

    assert_equal "/en/site/", @page.url(relative: true)
    assert_equal "/en/site/child-page", comfy_cms_pages(:child).url(relative: true)
  end

  def test_url_with_public_cms_path
    ComfortableMexicanSofa.config.public_cms_path = "/custom"
    assert_equal "//www.example.com/custom/", @page.url
    assert_equal "//www.example.com/custom/child-page", comfy_cms_pages(:child).url

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
    I18n.locale = :fr

    translation = comfy_cms_translations(:default)
    translation.update_columns(layout_id: comfy_cms_layouts(:nested).id)

    @page.translate!
    assert @page.readonly?

    assert_equal comfy_cms_layouts(:nested), @page.layout
    assert_equal "Default Translation", @page.label
    assert_equal "Translation Content", @page.content_cache

    frag = @page.fragments.find { |f| f.identifier == "content" }
    assert_equal "translated content", frag.content
  end

  def test_translate_with_no_translations
    I18n.locale = :fr
    Comfy::Cms::Translation.delete_all

    @page.translate!
    assert_equal "Default Page", @page.label
  end

  def test_translate_with_default_locale
    I18n.locale = @page.site.locale

    @page.translate!
    assert_equal "Default Page", @page.label
  end

  def test_translate_with_unpublished
    I18n.locale = :fr

    comfy_cms_translations(:default).update_column(:is_published, false)
    assert_exception_raised ActiveRecord::RecordNotFound do
      @page.translate!
    end
  end

  def test_translate_with_invalid_locale
    I18n.locale = :es

    assert_exception_raised ActiveRecord::RecordNotFound do
      @page.translate!
    end
  end

end
