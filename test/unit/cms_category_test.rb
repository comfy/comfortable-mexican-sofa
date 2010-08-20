require  File.dirname(__FILE__) + '/../test_helper'

class CmsCategoryTest < ActiveSupport::TestCase
  
  def test_fixtures_validity
    CmsCategory.all.each do |category|
      assert category.valid?, category.errors.full_messages
    end
  end

  def test_should_create_category
    assert_difference 'CmsCategory.count', 1 do
      CmsCategory.create(
        :label  => 'Test Category',
        :slug   => 'test_category',
        :description => 'Test Description'
      )
    end
  end
  
  def test_validation_on_blank
    assert_no_difference 'CmsCategory.count' do
      c = CmsCategory.create(
        :label  =>'', 
        :slug   =>''
      )
      assert c.errors[:label]
      assert c.errors[:slug]
    end
  end
  
  def test_validation_on_existing_slug
    assert_no_difference 'CmsCategory.count' do
      c = CmsCategory.create(
        :label  => 'Test Category',
        :slug   => cms_categories(:category_1).slug
      )
      assert c.errors[:slug]
    end
  end
  
  def test_removing_category_blows_away_children_and_categorizations
    category = cms_categories(:category_2)
    
    assert_equal 2, category.children.count
    
    assert_equal 2, category.cms_page_categorizations.count
    assert_equal 2, category.cms_pages.count
    
    assert_no_difference ['CmsPage.count'] do
      assert_difference ['CmsCategory.count'], -3 do
        assert_difference ['CmsPageCategorization.count'], -4 do # -2 from child categories
          category.destroy
        end
      end
    end
  end

  def test_categorized_model_names
    model_names = CmsCategory.categorized_model_names
    assert model_names.include?("CmsPage"), "CmsPage was not listed as categorized"
    assert !model_names.include?("CmsPageCategorization"), "CmsPageCategorizations was listed as categorized"
    assert !model_names.include?("CmsCategory"), "CmsCategory was listed as categorized"
  end

  def test_categorized_model_types
    model_types = CmsCategory.categorized_model_types
    assert model_types.include?(CmsPage), "CmsPage was not listed as categorized"
    assert !model_types.include?(CmsPageCategorization), "CmsPageCategorizations was listed as categorized"
    assert !model_types.include?(CmsCategory), "CmsCategory was listed as categorized"
  end

  def test_number_of_records
    assert_equal 2, cms_categories(:category_2).number_of_records
    assert_equal 1, cms_categories(:category_2_1).number_of_records
    assert_equal 1, cms_categories(:category_2_2).number_of_records
    assert_equal 0, cms_categories(:category_1).number_of_records
  end

  def test_records
    assert cms_categories(:category_2).records[:cms_pages].include?(cms_pages(:default))
    assert cms_categories(:category_2).records[:cms_pages].include?(cms_pages(:complex))
    assert cms_categories(:category_2_1).records[:cms_pages].include?(cms_pages(:default))
    assert cms_categories(:category_2_2).records[:cms_pages].include?(cms_pages(:default))
    assert cms_categories(:category_1).records[:cms_pages].empty?
  end
    
  
  def test_should_set_slug_if_blank
    c = CmsCategory.new(
      :label => 'Test Category'
    )
    assert c.valid?
    assert_equal 'test-category', c.slug
  end
end
