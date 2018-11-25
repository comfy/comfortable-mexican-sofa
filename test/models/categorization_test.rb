# frozen_string_literal: true

require_relative "../test_helper"

class CmsCategorizationTest < ActiveSupport::TestCase

  setup do
    @category = comfy_cms_categories(:default)
  end

  def test_fixtures_validity
    Comfy::Cms::Categorization.all.each do |categorization|
      assert categorization.valid?, categorization.errors.full_messages.to_s
    end
  end

  def test_validation
    category = Comfy::Cms::Categorization.new
    assert category.invalid?
    assert_has_errors_on category, :category, :categorized
  end

  def test_creation
    assert_difference "Comfy::Cms::Categorization.count" do
      @category.categorizations.create!(
        categorized: comfy_cms_pages(:default)
      )
    end
  end

  def test_categorized_relationship
    file = comfy_cms_files(:default)
    assert file.respond_to?(:category_ids)
    assert_equal 1, file.categories.count
    assert_equal @category, file.categories.first

    assert comfy_cms_pages(:default).respond_to?(:category_ids)
    assert_equal 0, comfy_cms_pages(:default).categories.count
  end

  def test_categorized_destruction
    file_count            = -> { Comfy::Cms::File.count }
    categorization_count  = -> { Comfy::Cms::Categorization.count }

    assert_difference([file_count, categorization_count], -1) do
      comfy_cms_files(:default).destroy
    end
  end

  def test_categorized_syncing
    # or we're not going to be able to link
    @category.update_column(:categorized_type, "Comfy::Cms::Page")

    page = comfy_cms_pages(:default)
    assert_equal 0, page.categories.count

    page.update(category_ids: [@category.id, 9999])

    page.reload
    assert_equal 1, page.categories.count

    page.update(category_ids: [])
    page.reload
    assert_equal 0, page.categories.count
  end

  def test_scope_for_category
    category = @category
    assert_equal 1, Comfy::Cms::File.for_category(category.label).count
    assert_equal 0, Comfy::Cms::File.for_category("invalid").count
    assert_equal 1, Comfy::Cms::File.for_category(category.label, "invalid").count
    assert_equal 1, Comfy::Cms::File.for_category(nil).count

    new_category = comfy_cms_sites(:default).categories.create!(
      label:            "Test Category",
      categorized_type: "Comfy::Cms::File"
    )
    new_category.categorizations.create!(categorized: comfy_cms_pages(:default))
    assert_equal 1, Comfy::Cms::File.for_category(category.label, new_category.label).to_a.size
    assert_equal 1,
      Comfy::Cms::File.for_category(category.label, new_category.label).distinct.count("comfy_cms_files.id")
  end

end
