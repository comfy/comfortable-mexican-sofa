require 'test_helper'

class CmsPageCategorizationTest < ActiveSupport::TestCase
  
  def test_fixtures_validity
    CmsPageCategorization.all.each do |categorization|
      assert categorization.valid?, categorization.errors.full_messages
    end
  end
  
  def test_creation
    assert_difference 'CmsPageCategorization.count' do
      CmsPageCategorization.create(
        :cms_page => cms_pages(:complex),
        :cms_category => cms_categories(:category_1)
      )
    end
  end
  
  def test_cascading_creation
    assert_difference 'CmsPageCategorization.count', 2 do
      CmsPageCategorization.create(
        :cms_page => cms_pages(:unpublished),
        :cms_category => cms_categories(:category_2_1)
      )
    end
  end
  
  def test_cascading_removal
    categorization = cms_page_categorizations(:page_category_1)
    assert_difference 'CmsPageCategorization.count', -3 do
      categorization.destroy
    end
  end
  
end

