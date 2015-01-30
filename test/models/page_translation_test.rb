# encoding: utf-8

require_relative '../test_helper'

class CmsPageTranslationTest < ActiveSupport::TestCase
  def test_fixtures_validity
    Comfy::Cms::Page::Translation.all.each do |translation|
      assert translation.valid?, translation.errors.full_messages.to_s
      assert_equal translation.content_cache, translation.render
    end
  end

  def test_validations
    translation = Comfy::Cms::Page::Translation.new
    translation.save
    assert translation.invalid?
    assert_has_errors_on translation, :translateable, :locale, :slug
  end

  def test_validation_of_target_page
    translation = comfy_cms_page_translations(:default)
    translation.target_page = comfy_cms_pages(:child)
    translation.save!
    assert_equal comfy_cms_pages(:child), translation.target_page
    translation.target_page = translation.translateable
    assert translation.invalid?
    assert_has_errors_on translation, :target_page_id
  end

  def test_allow_only_one_translation_per_locale
    translation = comfy_cms_pages(:default).translations.new(new_params)
    assert translation.invalid?
    assert_has_errors_on translation, :locale
  end

  def test_creation
    assert_difference ['Comfy::Cms::Translation.count', 'Comfy::Cms::Block.count'] do
      translation = comfy_cms_pages(:default).translations.create!(
        :locale  => :es,
        :slug   => 'test',
        :blocks_attributes => [
          { :identifier => 'default_translation_text',
            :content    => 'test' }
        ]
      )
      assert translation.is_published?
    end
  end

  def test_initialization_of_full_path
    translation = comfy_cms_pages(:default).translations.new
    assert_equal '/', translation.full_path

    translation = comfy_cms_pages(:child).translations.new(new_params)
    assert translation.valid?
    assert_equal '/test-translation', translation.full_path

    page = comfy_cms_sites(:default).pages.create!(new_page_params(:parent => comfy_cms_pages(:child)))
    translation = page.translations.new(new_params)
    assert_equal '/child-page/test-page', page.full_path
    assert_equal '/child-page/test-translation', translation.full_path
  end

  def test_syncronization_of_full_path
    page = comfy_cms_pages(:child)
    page_1 = comfy_cms_sites(:default).pages.create!(new_page_params(:parent => page, :slug => 'test-page-1'))
    translation_1 = page_1.translations.create!(new_params(:slug => 'test-translation-1'))
    page_2 = comfy_cms_sites(:default).pages.create!(new_page_params(:parent => page_1, :slug => 'test-page-2'))
    translation_2 = page_2.translations.create!(new_params(:slug => 'test-translation-2'))
    assert_equal '/child-page/test-page-1', page_1.full_path
    assert_equal '/child-page/test-translation-1', translation_1.full_path
    assert_equal '/child-page/test-page-1/test-page-2', page_2.full_path
    assert_equal '/child-page/test-translation-1/test-translation-2', translation_2.full_path

    page.update_attributes!(:slug => 'updated-page')
    assert_equal '/updated-page', page.full_path
    page_1.reload; page_2.reload; translation_1.reload; translation_2.reload
    assert_equal '/updated-page/test-page-1', page_1.full_path
    assert_equal '/updated-page/test-translation-1', translation_1.full_path
    assert_equal '/updated-page/test-page-1/test-page-2', page_2.full_path
    assert_equal '/updated-page/test-translation-1/test-translation-2', translation_2.full_path

    page_2.update_attributes!(:parent => page)
    page_1.reload; page_2.reload; translation_1.reload; translation_2.reload
    assert_equal '/updated-page/test-page-1', page_1.full_path
    assert_equal '/updated-page/test-translation-1', translation_1.full_path
    assert_equal '/updated-page/test-page-2', page_2.full_path
    assert_equal '/updated-page/test-translation-2', translation_2.full_path
  end

  def test_delegating_site
    translation = comfy_cms_page_translations(:default)
    assert_equal translation.site, comfy_cms_sites(:default)
  end

  def test_delegating_layout
    translation = comfy_cms_page_translations(:default)
    assert_equal translation.layout, comfy_cms_layouts(:default)
  end

  def test_cascading_destroy
    assert_difference 'Comfy::Cms::Page.count', -2 do
      assert_difference 'Comfy::Cms::Page::Translation.count', -1 do
        comfy_cms_pages(:default).destroy
      end
    end
  end

protected

  def new_params(options = {})
    {
      :locale  => :de,
      :slug   => 'test-translation'
    }.merge(options)
  end

  def new_page_params(options = {})
    {
      :label  => 'Test Page',
      :slug   => 'test-page',
      :layout => comfy_cms_layouts(:default)
    }.merge(options)
  end
end
