require_relative "../test_helper"

class CmsCategorizationTest < ActiveSupport::TestCase

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
      comfy_cms_categories(:default).categorizations.create!(
        categorized: comfy_cms_pages(:default)
      )
    end
  end

  def test_categorized_relationship
    snippet = comfy_cms_snippets(:default)
    assert snippet.respond_to?(:category_ids)
    assert_equal 1, snippet.categories.count
    assert_equal comfy_cms_categories(:default), snippet.categories.first

    assert comfy_cms_pages(:default).respond_to?(:category_ids)
    assert_equal 0, comfy_cms_pages(:default).categories.count
  end

  def test_categorized_destruction
    assert_difference ["Comfy::Cms::Snippet.count", "Comfy::Cms::Categorization.count"], -1 do
      comfy_cms_snippets(:default).destroy
    end
  end

  def test_categorized_syncing
    page = comfy_cms_pages(:default)
    assert_equal 0, page.categories.count

    page.update_attributes(:category_ids => {
      comfy_cms_categories(:default).id => 1,
      "invalid"                         => 1
    })
    page.reload
    assert_equal 1, page.categories.count

    page.update_attributes(:category_ids => {
      comfy_cms_categories(:default).id => 0,
      "invalid"                         => 0
    })
    page.reload
    assert_equal 0, page.categories.count
  end

  def test_scope_for_category
    category = comfy_cms_categories(:default)
    assert_equal 1, Comfy::Cms::Snippet.for_category(category.label).count
    assert_equal 0, Comfy::Cms::Snippet.for_category("invalid").count
    assert_equal 1, Comfy::Cms::Snippet.for_category(category.label, "invalid").count
    assert_equal 1, Comfy::Cms::Snippet.for_category(nil).count

    new_category = comfy_cms_sites(:default).categories.create!(
      label:            "Test Category",
      categorized_type: "Comfy::Cms::Snippet"
    )
    new_category.categorizations.create!(categorized: comfy_cms_pages(:default))
    assert_equal 1, Comfy::Cms::Snippet.for_category(category.label, new_category.label).to_a.size
    assert_equal 1, Comfy::Cms::Snippet.for_category(category.label, new_category.label).distinct.count("comfy_cms_snippets.id")
  end
end
