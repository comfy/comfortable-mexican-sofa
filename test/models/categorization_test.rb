require_relative '../test_helper'

class CmsCategorizationTest < ActiveSupport::TestCase
  
  def test_fixtures_validity
    Cms::Categorization.all.each do |categorization|
      assert categorization.valid?, categorization.errors.full_messages.to_s
    end
  end
  
  def test_validation
    category = Cms::Categorization.new
    assert category.invalid?
    assert_has_errors_on category, :category_id, :categorized_type, :categorized_id
  end
  
  def test_creation
    assert_difference 'Cms::Categorization.count' do
      categorization = cms_categories(:default).categorizations.create!(
        :categorized => cms_snippets(:default)
      )
    end
  end
  
  def test_categorized_relationship
    file = cms_files(:default)
    assert file.respond_to?(:category_ids)
    assert_equal 1, file.categories.count
    assert_equal cms_categories(:default), file.categories.first
    
    assert cms_snippets(:default).respond_to?(:category_ids)
    assert_equal 0, cms_snippets(:default).categories.count
    assert cms_pages(:default).respond_to?(:category_ids)
    assert_equal 0, cms_pages(:default).categories.count
  end
  
  def test_categorized_destruction
    file = cms_files(:default)
    assert_difference ['Cms::File.count', 'Cms::Categorization.count'], -1 do
      file.destroy
    end
  end
  
  def test_categorized_syncing
    snippet = cms_snippets(:default)
    assert_equal 0, snippet.categories.count
    
    snippet.update_attributes(:category_ids => {
      cms_categories(:default).id => 1,
      'invalid'                   => 1
    })
    snippet.reload
    assert_equal 1, snippet.categories.count
    
    snippet.update_attributes(:category_ids => {
      cms_categories(:default).id => 0,
      'invalid'                   => 0
    })
    snippet.reload
    assert_equal 0, snippet.categories.count
  end
  
  def test_scope_for_category
    category = cms_categories(:default)
    assert_equal 1, Cms::File.for_category(category.label).count
    assert_equal 0, Cms::File.for_category('invalid').count
    assert_equal 1, Cms::File.for_category(category.label, 'invalid').count
    assert_equal 1, Cms::File.for_category(nil).count
    
    new_category = cms_sites(:default).categories.create!(:label => 'Test Category', :categorized_type => 'Cms::File')
    new_category.categorizations.create!(:categorized => cms_files(:default))
    assert_equal 1, Cms::File.for_category(category.label, new_category.label).to_a.size
    assert_equal 1, Cms::File.for_category(category.label, new_category.label).distinct.count('cms_files.id')
  end
  
end