# encoding: utf-8

require_relative '../../test_helper'

class CmsPageTest < ActiveSupport::TestCase
  
  def test_fixtures_validity
    Cms::Page.all.each do |page|
      assert page.valid?, page.errors.full_messages.to_s
    end
  end
  
  def test_validations
    page = Cms::Page.new
    page.save
    assert page.invalid?
    assert_has_errors_on page, :site_id, :layout, :label
  end

  def test_validation_of_parent_presence
    page = cms_sites(:default).pages.new(new_params)
    assert !page.parent
    assert page.valid?, page.errors.full_messages.to_s
    assert_equal cms_pages(:default), page.parent
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
  
  def test_validation_of_target_page
    page = cms_pages(:child)
    page.target_page = cms_pages(:default)
    page.save!
    assert_equal cms_pages(:default), page.target_page
    page.target_page = page
    assert page.invalid?
    assert_has_errors_on page, :target_page_id
  end

  def test_page_content_attributes_assignment_for_new
    page = Cms::Page.new
    page.page_content_attributes = {:slug => 'test'}
    
    assert_equal 1, page.page_contents.size
    page_content = page.page_contents.first
    assert_equal 'test', page_content.slug
    assert_equal page_content, page.page_content
  end
  
  def test_page_content_attributes_assignment_for_existing
    page          = cms_pages(:default)
    page_content  = cms_page_contents(:default)
    page.page_content_attributes = {:id => page_content.id, :slug => 'updated'}
    
    assert_equal 1, page.page_contents.size
    assert_equal 'updated', page.page_contents.first.slug
    assert_equal page_content, page.page_content
  end
  
  def test_page_content
    page = cms_pages(:default)
    assert_equal cms_page_contents(:default), page.page_content
  end

  def test_page_content_with_variation
    ComfortableMexicanSofa.config.variations = ['en', 'fr']
    page          = cms_pages(:default)
    page_content  = cms_page_contents(:default)
    
    assert_equal page_content, page.page_content('en', :reload)
    assert_equal page_content, page.page_content('fr', :reload)
    assert_nil   page.page_content('invalid', :reload)
  end
  
  def test_page_content_as_new
    page = Cms::Page.new
    assert page.page_content.is_a?(Cms::PageContent)
  end
   
  def test_content
    page = cms_pages(:default)
    assert page.content.present?
  end

  def test_update_of_page_content
    page_content = cms_page_contents(:default)
    assert_no_difference ['Cms::PageContent.count'] do
      cms_pages(:default).update_attributes!(
        :layout  => cms_layouts(:default),
        :page_content_attributes => {
          :id    => page_content.id,
          :slug  => 'updated'
        }
      )
    end
    page_content.reload
    assert_equal 'updated', page_content.slug
  end

  def test_label_assignment
    page = cms_sites(:default).pages.new(
      :parent => cms_pages(:default),
      :layout => cms_layouts(:default),
      :label  => 'Example'
    )
    assert page.valid?
    assert_equal 'Example', page.label
  end
  
  def test_creation
    assert_difference ['Cms::Page.count', 'Cms::PageContent.count', 'Cms::Block.count'] do
      page = cms_sites(:default).pages.create!(
        :label  => 'test',
        :parent => cms_pages(:default),
        :layout => cms_layouts(:default),
        :page_content_attributes => {
          :slug => 'test',
          :variation_identifiers => {'en' => 1},
          :blocks_attributes => [
            { :identifier => 'default_page_text',
              :content    => 'test' }
          ]
        }
      )
      assert page.is_published?
      assert_equal 1, page.position
    end
  end
  
  def test_initialization_of_full_path
    skip
    page = Cms::Page.new
    assert_equal '/', page.full_path
    
    page = Cms::Page.new(new_params)
    assert page.invalid?
    assert_has_errors_on page, :site_id
    
    page = cms_sites(:default).pages.new(new_params(:parent => cms_pages(:default)))
    assert page.valid?
    assert_equal '/test-page', page.full_path
    
    page = cms_sites(:default).pages.new(new_params(:parent => cms_pages(:child)))
    assert page.valid?
    assert_equal '/child-page/test-page', page.full_path
    
    Cms::Page.destroy_all
    page = cms_sites(:default).pages.new(new_params)
    assert page.valid?
    assert_equal '/', page.full_path
  end
  
  def test_sync_child_pages
    skip
    page = cms_pages(:child)
    page_1 = cms_sites(:default).pages.create!(new_params(:parent => page, :slug => 'test-page-1'))
    page_2 = cms_sites(:default).pages.create!(new_params(:parent => page, :slug => 'test-page-2'))
    page_3 = cms_sites(:default).pages.create!(new_params(:parent => page_2, :slug => 'test-page-3'))
    page_4 = cms_sites(:default).pages.create!(new_params(:parent => page_1, :slug => 'test-page-4'))
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
    
    page_3 = cms_sites(:default).pages.create!(new_params(:parent => page_2))
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
    assert_difference 'Cms::Page.count', -2 do
      assert_difference 'Cms::Block.count', -2 do
        cms_pages(:default).destroy
      end
    end
  end
  
  def test_options_for_select
    assert_equal ['Default Page', '. . Child Page'], 
      Cms::Page.options_for_select(cms_sites(:default)).collect{|t| t.first }
    assert_equal ['Default Page'], 
      Cms::Page.options_for_select(cms_sites(:default), cms_pages(:child)).collect{|t| t.first }
    assert_equal [], 
      Cms::Page.options_for_select(cms_sites(:default), cms_pages(:default))
    
    page = Cms::Page.new(new_params(:parent => cms_pages(:default)))
    assert_equal ['Default Page', '. . Child Page'],
      Cms::Page.options_for_select(cms_sites(:default), page).collect{|t| t.first }
  end
    
  def test_content_caching
    skip
    page = cms_pages(:default)
    assert_equal page.read_attribute(:content), page.content
    assert_equal page.read_attribute(:content), page.content(true)
    
    page.update_attributes(:content => 'changed')
    assert_equal page.read_attribute(:content), page.content
    assert_equal page.read_attribute(:content), page.content(true)
    assert_not_equal 'changed', page.read_attribute(:content)
  end
  
  def test_scope_published
    assert_equal 2, Cms::Page.published.count
    cms_pages(:child).update_columns(:is_published => false)
    assert_equal 1, Cms::Page.published.count
  end
  
  def test_root
    assert cms_pages(:default).root?
    assert !cms_pages(:child).root?
  end

  def test_default_path
    parent = cms_pages(:default)
    child = cms_pages(:child)
    assert_equal parent.page_content.slug, parent.default_slug
  end

  def test_has_variation
    page = cms_pages(:default)
    assert page.has_variation?('en')
    assert page.has_variation?('fr')
    assert page.has_variation?(['en', 'fr'])
    assert !page.has_variation?(['en', 'invalid'])
    assert !page.has_variation?('invalid')
  end

protected
  
  def new_params(options = {})
    {
      :label  => 'Test Page',
      :slug   => 'test-page',
      :layout => cms_layouts(:default)
    }.merge(options)
  end
end
