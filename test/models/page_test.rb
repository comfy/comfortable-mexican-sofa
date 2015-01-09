# encoding: utf-8

require_relative '../test_helper'

class CmsPageTest < ActiveSupport::TestCase

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
    assert_has_errors_on page, :site_id, :layout, :slug, :label
  end

  def test_validation_of_parent_presence
    page = comfy_cms_sites(:default).pages.new(new_params)
    assert !page.parent
    assert page.valid?, page.errors.full_messages.to_s
    assert_equal comfy_cms_pages(:default), page.parent
  end

  def test_validation_of_parent_relationship
    page = comfy_cms_pages(:default)
    assert !page.parent
    page.parent = page
    assert page.invalid?
    assert_has_errors_on page, :parent_id
    page.parent = comfy_cms_pages(:child)
    assert page.invalid?
    assert_has_errors_on page, :parent_id
  end

  def test_validation_of_target_page
    page = comfy_cms_pages(:child)
    page.target_page = comfy_cms_pages(:default)
    page.save!
    assert_equal comfy_cms_pages(:default), page.target_page
    page.target_page = page
    assert page.invalid?
    assert_has_errors_on page, :target_page_id
  end

  def test_validation_of_slug
    page = comfy_cms_pages(:child)
    page.slug = 'slug.with.d0ts-and_things'
    assert page.valid?

    page.slug = 'inva lid'
    assert page.invalid?

    page.slug = 'acción'
    assert page.valid?
  end

  def test_validation_of_slug_allows_unicode_accent_characters
    page = comfy_cms_pages(:child)
    thai_character_ko_kai = "\u0e01"
    thai_character_mai_tho = "\u0E49"
    page.slug = thai_character_ko_kai + thai_character_mai_tho
    assert page.valid?
  end

  def test_label_assignment
    page = comfy_cms_sites(:default).pages.new(
      :slug   => 'test',
      :parent => comfy_cms_pages(:default),
      :layout => comfy_cms_layouts(:default)
    )
    assert page.valid?
    assert_equal 'Test', page.label
  end

  def test_creation
    assert_difference ['Comfy::Cms::Page.count', 'Comfy::Cms::Block.count'] do
      page = comfy_cms_sites(:default).pages.create!(
        :label  => 'test',
        :slug   => 'test',
        :parent => comfy_cms_pages(:default),
        :layout => comfy_cms_layouts(:default),
        :blocks_attributes => [
          { :identifier => 'default_page_text',
            :content    => 'test' }
        ]
      )
      assert page.is_published?
      assert_equal 1, page.position
    end
  end

  def test_initialization_of_full_path
    page = Comfy::Cms::Page.new
    assert_equal '/', page.full_path

    page = Comfy::Cms::Page.new(new_params)
    assert page.invalid?
    assert_has_errors_on page, :site_id

    page = comfy_cms_sites(:default).pages.new(new_params(:parent => comfy_cms_pages(:default)))
    assert page.valid?
    assert_equal '/test-page', page.full_path

    page = comfy_cms_sites(:default).pages.new(new_params(:parent => comfy_cms_pages(:child)))
    assert page.valid?
    assert_equal '/child-page/test-page', page.full_path

    Comfy::Cms::Page.destroy_all
    page = comfy_cms_sites(:default).pages.new(new_params)
    assert page.valid?
    assert_equal '/', page.full_path
  end

  def test_sync_child_pages
    page = comfy_cms_pages(:child)
    page_1 = comfy_cms_sites(:default).pages.create!(new_params(:parent => page, :slug => 'test-page-1'))
    page_2 = comfy_cms_sites(:default).pages.create!(new_params(:parent => page, :slug => 'test-page-2'))
    page_3 = comfy_cms_sites(:default).pages.create!(new_params(:parent => page_2, :slug => 'test-page-3'))
    page_4 = comfy_cms_sites(:default).pages.create!(new_params(:parent => page_1, :slug => 'test-page-4'))
    assert_equal '/child-page/test-page-1', page_1.full_path
    assert_equal '/child-page/test-page-2', page_2.full_path
    assert_equal '/child-page/test-page-2/test-page-3', page_3.full_path
    assert_equal '/child-page/test-page-1/test-page-4', page_4.full_path

    page.update_attributes!(:slug => 'updated-page')
    assert_equal '/updated-page', page.full_path
    page_1.reload; page_2.reload; page_3.reload; page_4.reload
    assert_equal '/updated-page/test-page-1', page_1.full_path
    assert_equal '/updated-page/test-page-2', page_2.full_path
    assert_equal '/updated-page/test-page-2/test-page-3', page_3.full_path
    assert_equal '/updated-page/test-page-1/test-page-4', page_4.full_path

    page_2.update_attributes!(:parent => page_1)
    page_1.reload; page_2.reload; page_3.reload; page_4.reload
    assert_equal '/updated-page/test-page-1', page_1.full_path
    assert_equal '/updated-page/test-page-1/test-page-2', page_2.full_path
    assert_equal '/updated-page/test-page-1/test-page-2/test-page-3', page_3.full_path
    assert_equal '/updated-page/test-page-1/test-page-4', page_4.full_path
  end

  def test_children_count_updating
    page_1 = comfy_cms_pages(:default)
    page_2 = comfy_cms_pages(:child)
    assert_equal 1, page_1.children_count
    assert_equal 0, page_2.children_count

    page_3 = comfy_cms_sites(:default).pages.create!(new_params(:parent => page_2))
    page_1.reload; page_2.reload
    assert_equal 1, page_1.children_count
    assert_equal 1, page_2.children_count
    assert_equal 0, page_3.children_count

    page_3.update_attributes!(:parent => page_1)
    page_1.reload; page_2.reload
    assert_equal 2, page_1.children_count
    assert_equal 0, page_2.children_count

    page_3.destroy
    page_1.reload; page_2.reload
    assert_equal 1, page_1.children_count
    assert_equal 0, page_2.children_count
  end

  def test_cascading_destroy
    assert_difference 'Comfy::Cms::Page.count', -2 do
      assert_difference 'Comfy::Cms::Block.count', -2 do
        comfy_cms_pages(:default).destroy
      end
    end
  end

  def test_options_for_select
    assert_equal ['Default Page', '. . Child Page'],
      Comfy::Cms::Page.options_for_select(comfy_cms_sites(:default)).collect{|t| t.first }
    assert_equal ['Default Page'],
      Comfy::Cms::Page.options_for_select(comfy_cms_sites(:default), comfy_cms_pages(:child)).collect{|t| t.first }
    assert_equal [],
      Comfy::Cms::Page.options_for_select(comfy_cms_sites(:default), comfy_cms_pages(:default))

    page = Comfy::Cms::Page.new(new_params(:parent => comfy_cms_pages(:default)))
    assert_equal ['Default Page', '. . Child Page'],
      Comfy::Cms::Page.options_for_select(comfy_cms_sites(:default), page).collect{|t| t.first }
  end

  def test_comfy_cms_blocks_attributes_accessor
    page = comfy_cms_pages(:default)
    assert_equal page.blocks.count, page.blocks_attributes.size
    assert_equal 'default_field_text', page.blocks_attributes.first[:identifier]
    assert_equal 'default_field_text_content', page.blocks_attributes.first[:content]
  end

  def test_content_caching
    page = comfy_cms_pages(:default)
    assert_equal page.content_cache, page.render

    page.update_columns(:content_cache => 'Old Content')
    refute_equal page.content_cache, page.render

    page.clear_content_cache!
    assert_equal page.content_cache, page.render
  end

  def test_content_cache_clear_on_save
    page = comfy_cms_pages(:default)
    old_content = 'Old Content'
    page.update_columns(:content_cache => old_content)

    page.save!
    refute_equal old_content, page.content_cache
  end

  def test_scope_published
    assert_equal 2, Comfy::Cms::Page.published.count
    comfy_cms_pages(:child).update_columns(:is_published => false)
    assert_equal 1, Comfy::Cms::Page.published.count
  end

  def test_root?
    assert comfy_cms_pages(:default).root?
    assert !comfy_cms_pages(:child).root?
  end

  def test_url
    site = comfy_cms_sites(:default)

    assert_equal '//test.host/', comfy_cms_pages(:default).url
    assert_equal '//test.host/child-page', comfy_cms_pages(:child).url

    assert_equal '/', comfy_cms_pages(:default).url(:relative)
    assert_equal '/child-page', comfy_cms_pages(:child).url(:relative)

    site.update_columns(:path => '/en/site')
    comfy_cms_pages(:default).reload
    comfy_cms_pages(:child).reload

    assert_equal '//test.host/en/site/', comfy_cms_pages(:default).url
    assert_equal '//test.host/en/site/child-page', comfy_cms_pages(:child).url

    assert_equal '/en/site/', comfy_cms_pages(:default).url(:relative)
    assert_equal '/en/site/child-page', comfy_cms_pages(:child).url(:relative)
  end

  def test_url_with_public_cms_path
    ComfortableMexicanSofa.config.public_cms_path = '/custom'
    assert_equal '//test.host/custom/', comfy_cms_pages(:default).url
    assert_equal '//test.host/custom/child-page', comfy_cms_pages(:child).url

    assert_equal '/custom/', comfy_cms_pages(:default).url(:relative)
    assert_equal '/custom/child-page', comfy_cms_pages(:child).url(:relative)
  end

  def test_unicode_slug_escaping
    page = comfy_cms_pages(:child)
    page_1 = comfy_cms_sites(:default).pages.create!(new_params(:parent => page, :slug => 'tést-ünicode-slug'))
    assert_equal CGI::escape('tést-ünicode-slug'), page_1.slug
    assert_equal CGI::escape('/child-page/tést-ünicode-slug').gsub('%2F', '/'), page_1.full_path
  end

  def test_unicode_slug_unescaping
    page = comfy_cms_pages(:child)
    page_1 = comfy_cms_sites(:default).pages.create!(new_params(:parent => page, :slug => 'tést-ünicode-slug'))
    found_page = comfy_cms_sites(:default).pages.where(:slug => CGI::escape('tést-ünicode-slug')).first
    assert_equal 'tést-ünicode-slug', found_page.slug
    assert_equal '/child-page/tést-ünicode-slug', found_page.full_path
  end

  def test_identifier
    assert_equal 'index',       comfy_cms_pages(:default).identifier
    assert_equal 'child-page',  comfy_cms_pages(:child).identifier

    comfy_cms_pages(:default).update_column(:slug, 'index')
    assert_equal 'index', comfy_cms_pages(:default).identifier
  end

  def test_children_count_updating_on_move
    page_1 = comfy_cms_pages(:default)
    page_2 = comfy_cms_pages(:child)
    page_3 = comfy_cms_sites(:default).pages.create!(new_params(:parent => page_2))

    page_2.reload

    assert_equal 1, page_1.children_count
    assert_equal 1, page_2.children_count
    assert_equal 0, page_3.children_count

    page_3.parent_id = page_1.id
    page_3.save!

    page_1.reload; page_2.reload; page_3.reload

    assert_equal 2, page_1.children_count
    assert_equal 0, page_2.children_count
    assert_equal 0, page_3.children_count
  end

protected

  def new_params(options = {})
    {
      :label  => 'Test Page',
      :slug   => 'test-page',
      :layout => comfy_cms_layouts(:default)
    }.merge(options)
  end
end
