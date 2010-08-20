require 'test_helper'

class CmsLayoutTest < ActiveSupport::TestCase
  
  def test_fixtures_validity
    CmsLayout.all.each do |layout|
      assert layout.valid?, layout.errors.full_messages
    end
  end
  
  def test_nested_layouts
    parent_layout = cms_layouts(:default)
    child_layout = cms_layouts(:nested)
    assert_equal parent_layout, child_layout.parent
    assert parent_layout.is_extendable?
    
    assert_not_equal child_layout.content, child_layout.read_attribute(:content)
    parent_layout_content = '{{ cms_block:header:string }}{{ cms_page_block:default:text }}{{ cms_page_block:footer:text }}'
    child_layout_content = '{{ cms_block:header:string }}{{ cms_page_block:left_column:text }}{{ cms_page_block:right_column:text }}{{ cms_snippet:complex_snippet }}{{ cms_page_block:footer:text }}'
    
    assert_equal parent_layout_content, parent_layout.content
    assert_equal child_layout_content, child_layout.content
  end
  
  def test_adding_new_block_tag_updates_associated_pages
    layout = cms_layouts(:default)
    page = cms_pages(:default)
    assert_equal layout, page.cms_layout
    assert_equal 3, layout.tags.size
    assert_equal 3, layout.tags.select{|t| ['cms_block', 'cms_page_block'].member?(t.tag_type)}.size
    assert_equal 3, page.cms_blocks.count
    
    assert_difference ['layout.tags.size', 'page.cms_blocks.count'] do
      layout.content += "{{cms_block:new_block:string}}"
      layout.save!
      layout.reload
      page.reload
      
      assert layout.tags.collect{|t| t.tag_signature}.member?('cms_block:new_block:string')
      assert page.cms_blocks.with_label('new_block')
    end
  end

end
