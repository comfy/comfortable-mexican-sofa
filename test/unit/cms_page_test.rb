require File.dirname(__FILE__) + '/../test_helper'

class CmsPageTest < ActiveSupport::TestCase
  
  def test_initialization
    page = CmsPage.new
    assert page.cms_layout
    assert_equal cms_layouts(:default), CmsLayout.first
    assert_equal cms_layouts(:default), page.cms_layout
  end
    
  def test_initialization_with_parent_page
    assert cms_layouts(:nested), cms_pages(:complex).cms_layout

    assert_difference 'CmsPage.find_by_slug("complex-page").children_count', 1 do
      page = CmsPage.new(
        :label => "test child",
        :slug => "test-child",
        :parent => cms_pages(:complex)
      )
      page.save!
      assert page.cms_layout
      assert_equal cms_pages(:complex).cms_layout, page.cms_layout

    end
  end
    
  def test_fixtures_validity
    CmsPage.all.each do |page|
      assert page.valid?, page.errors.full_messages
    end
  end
  
  def test_page_finder_helper
    page = cms_pages(:default)
    assert_equal page, CmsPage[page.slug]
  end
  
  def test_page_rendering
    page = cms_pages(:default)
    assert_equal 3, page.cms_blocks.count
    assert_equal '/page_block:default//page_block:footer/', page.render_content
  end
  
  def test_complex_nested_rendering
    page = cms_pages(:complex)
    assert_equal 4, page.cms_blocks.count
    assert_equal "/page_block:left_column/ /complex snippet//page_block:right_column/ <%= render :partial => 'complex_page/example' %>/complex snippet//page_block:footer/", page.render_content
  end
  
  def test_page_content
    page = cms_pages(:default)
    assert_equal page.content, page.render_content
  end
  
  def test_cms_block_content_method
    page = cms_pages(:default)
    assert !page.cms_block_content(:header, :content_string).blank?
    assert page.cms_block_content(:bogus_label, :content_string).blank?
  end
  
  def test_publishing
    page = cms_pages(:default)
    assert page.published?
    page.update_attribute(:published, false)
    assert !page.published?
  end
  
  def test_excluding_from_nav
    page = cms_pages(:default)
    assert !page.excluded_from_nav?
    page.update_attribute(:excluded_from_nav, true)
    assert page.excluded_from_nav?
  end
  
  def test_slug_changes_on_all_descendants
    page = cms_pages(:complex)
    assert_equal '/complex-page', page.full_path
    
    first_descendant = cms_pages(:descendant1)
    assert_equal '/complex-page/first-descendant', first_descendant.full_path
    
    second_descendant = cms_pages(:descendant2)
    assert_equal '/complex-page/first-descendant/second-descendant', second_descendant.full_path
    
    page.slug = 'complex'
    page.save!
    
    page.reload
    first_descendant.reload
    second_descendant.reload
    
    assert_equal '/complex', page.full_path
    assert_equal '/complex/first-descendant', first_descendant.full_path
    assert_equal '/complex/first-descendant/second-descendant', second_descendant.full_path
    
  end

  def test_child_count_updates_on_create
    assert_difference 'CmsPage.find_by_slug("complex-page").children_count', 1 do
      CmsPage.create!(
        :label => "test child",
        :slug => "test-child",
        :parent => cms_pages(:complex)
      )
    end
  end

  def test_child_count_updates_on_destroy
    assert_difference 'CmsPage.find_by_slug("complex-page").children_count', -1 do
      cms_pages(:descendant1).destroy
    end
  end

  def test_child_count_updates_on_parent_change
    CmsPage.repair_children_count

    assert_equal cms_pages(:complex2).children.count, cms_pages(:complex2).children_count
    assert_equal cms_pages(:complex).children.count, cms_pages(:complex).children_count

    assert_difference 'CmsPage.find_by_slug("complex-page").children_count', -1 do
      assert_difference 'CmsPage.find_by_slug("complex-page-2").children_count', 1 do
        pg = CmsPage.find_by_slug('first-descendant')
        pg.parent_id_will_change!
        pg.parent_id = cms_pages(:complex2).id
        pg.save!
      end
    end

  end
end
