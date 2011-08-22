require File.expand_path('../../test_helper', File.dirname(__FILE__))

class CmsCategorizationTest < ActiveSupport::TestCase
  
  def test_fixtures_validity
    Cms::Categorization.all.each do |categorization|
      assert categorization.valid?, categorization.errors.full_messages.to_s
    end
  end
  
  def test_validation
    category = Cms::Categorization.new
    assert category.invalid?
    assert_has_errors_on category, [:categorized_type, :categorized_id]
  end
  
  def test_creation
    assert_difference 'Cms::Categorization.count' do
      categorization = cms_categories(:default).categorizations.create!(
        :categorized => cms_snippets(:default)
      )
    end
  end
  
end