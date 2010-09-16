require File.dirname(__FILE__) + '/../test_helper'

class CmsTagTest < ActiveSupport::TestCase
  
  def test_initialization_and_rendering
   content = 'a <cms:page:tag_1> b <cms:page:tag_2> c'
   raise CmsTag.process_content(content).to_yaml
   
    
  end
  
  def test_method_find_cms_tags
    content = cms_layouts(:default).content
    assert_equal [
      '<cms:page:content/>',
      '<cms:page:title:string/>',
      '<cms:page:number:integer/>'
    ], CmsTag.find_cms_tags(content)
  end
  
  def test_initialize_tags
    content = cms_layouts(:default).content
    tags = CmsTag.initialize_tags(nil, content)
    assert_equal 3, tags.size
    assert_equal 3, (cms_blocks = tags.select{|t| t.class.superclass == CmsBlock}).count
    cms_blocks.each do |block|
      assert block.content.blank?
    end
  end
  
  def test_initialize_tags_for_a_saved_page
    tags = CmsTag.initialize_tags(cms_pages(:default))
    assert_equal 3, tags.size
    assert_equal 3, (cms_blocks = tags.select{|t| t.class.superclass == CmsBlock}).count
    cms_blocks.each do |block|
      assert !block.content.blank?
    end
  end
  
  def test_initialize_tags_for_initialized_page
    page = CmsPage.new
    assert_equal 0, CmsTag.initialize_tags(page).size
    page.cms_layout = cms_layouts(:default)
    assert_equal 3, CmsTag.initialize_tags(page).size
  end
  
end
