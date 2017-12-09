require_relative "../test_helper"

class CmsPageTest < ActiveSupport::TestCase

  setup do
    @page = comfy_cms_pages(:default)
  end

  def test_fixtures_validity
    Comfy::Cms::Translation.all.each do |translation|
      assert translation.valid?, translation.errors.full_messages.to_s
    end
  end

  def test_validations
    translation = Comfy::Cms::Translation.new
    translation.save
    assert translation.invalid?
    assert_has_errors_on translation, :page, :layout, :locale, :label
  end

  def test_validation_on_locale_uniqueness
    translation = @page.translations.new(
      label: "Test",
      locale: comfy_cms_translations(:default).locale
    )
    assert translation.invalid?
    assert_has_errors_on translation, :locale
  end

  def test_validation_on_locale_uniqueness_against_site
    translation = @page.translations.new(
      label: "Test",
      locale: comfy_cms_sites(:default).locale
    )
    assert translation.invalid?
    assert_has_errors_on translation, :locale
  end

  def test_creation
    assert_count_difference [Comfy::Cms::Translation, Comfy::Cms::Fragment] do
      translation = @page.translations.create(
        locale: "test",
        label:  "Test Translation",
        fragments_attributes: [
          { identifier: "content",
            tag:        "text",
            content:    "test" }
        ]
      )
      assert_equal @page.layout, translation.layout
    end
  end

  def test_scope_published
    assert_equal 1, Comfy::Cms::Translation.published.count
    comfy_cms_translations(:default).update_columns(is_published: false)
    assert_equal 0, Comfy::Cms::Translation.published.count
  end
end
