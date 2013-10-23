require_relative '../test_helper'

class CmsCategoryTest < ActiveSupport::TestCase
  
  def test_fixtures_validity
    Cms::Category.all.each do |category|
      assert category.valid?, category.errors.full_messages.to_s
    end
  end
  
  def test_validation
    category = Cms::Category.new
    assert category.invalid?
    assert_has_errors_on category, [:site_id, :label, :categorized_type]
  end
  
  def test_creation
    assert_difference 'Cms::Category.count' do
      cms_sites(:default).categories.create(
        :label => 'Test Category',
        :categorized_type => 'Cms::Snippet'
      )
    end
  end
  
  def test_destruction
    category = cms_categories(:default)
    assert_equal 1, category.categorizations.count
    assert_difference ['Cms::Category.count', 'Cms::Categorization.count'], -1 do
      category.destroy
    end
  end
  
  def test_scope_of_type
    assert_equal 1, Cms::Category.of_type('Cms::File').count
    assert_equal 0, Cms::Category.of_type('Invalid').count
  end
  
end