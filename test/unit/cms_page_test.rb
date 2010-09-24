require File.dirname(__FILE__) + '/../test_helper'

class CmsPageTest < ActiveSupport::TestCase
  
  def test_fixtures_validity
    CmsPage.all.each do |page|
      assert page.valid?, page.errors.full_messages
    end
  end
  
  def test_validations
    page = CmsPage.new
    page.save
    assert page.invalid?
    assert_has_errors_on page, [:cms_layout, :slug, :label]
  end
  
  def test_validation_of_parent_relationship
    page = cms_pages(:default)
    assert !page.parent
    page.parent = page
    assert page.invalid?
    assert_has_errors_on page, :parent_id
    page.parent = cms_pages(:child)
    assert page.invalid?
    assert_has_errors_on page, :parent_id
  end
  
  def test_initialization_of_full_path
    page = CmsPage.new(new_params)
    assert page.invalid?
    assert_has_errors_on page, :full_path
    
    page = CmsPage.new(new_params(:parent => cms_pages(:default)))
    assert page.valid?
    assert_equal '/test-page', page.full_path
    
    page = CmsPage.new(new_params(:parent => cms_pages(:child)))
    assert page.valid?
    assert_equal '/child-page/test-page', page.full_path
    
    CmsPage.destroy_all
    page = CmsPage.new(new_params)
    assert page.valid?
    assert_equal '/', page.full_path
  end
  
  def test_sync_child_pages
    page = cms_pages(:child)
    page_1 = CmsPage.create!(new_params(:parent => page, :slug => 'test-page-1'))
    page_2 = CmsPage.create!(new_params(:parent => page, :slug => 'test-page-2'))
    page_3 = CmsPage.create!(new_params(:parent => page_2, :slug => 'test-page-3'))
    page_4 = CmsPage.create!(new_params(:parent => page_1, :slug => 'test-page-4'))
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
    page_1 = cms_pages(:default)
    page_2 = cms_pages(:child)
    assert_equal 1, page_1.children_count
    assert_equal 0, page_2.children_count
    
    page_3 = CmsPage.create!(new_params(:parent => page_2))
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
    assert_difference 'CmsPage.count', -2 do
      cms_pages(:default).destroy
    end
  end
  
  def test_options_for_select
    assert_equal ['Default Page', '. . Child Page'], CmsPage.options_for_select.collect{|t| t.first }
    assert_equal ['Default Page'], CmsPage.options_for_select(cms_pages(:child)).collect{|t| t.first }
    assert_equal [], CmsPage.options_for_select(cms_pages(:default))
    
    page = CmsPage.new(new_params(:parent => cms_pages(:default)))
    assert_equal ['Default Page', '. . Child Page'], CmsPage.options_for_select(page).collect{|t| t.first }
  end
  
  def test_block_cms_tags
    page = cms_pages(:default)
    assert_equal 2, page.block_cms_tags.size
    assert_equal 'cms_tag/field_text_default_field_text', page.block_cms_tags[0].identifier
    assert_equal 'cms_tag/page_text_default_page_text', page.block_cms_tags[1].identifier
    assert_equal 4, page.cms_tags.size
  end
  
protected
  
  def new_params(options = {})
    {
      :label      => 'Test Page',
      :slug       => 'test-page',
      :cms_layout => cms_layouts(:default)
    }.merge(options)
  end
end
