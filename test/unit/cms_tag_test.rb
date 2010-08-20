require  File.dirname(__FILE__) + '/../test_helper'

class CmsTagTest < ActiveSupport::TestCase
  
  def test_tag_parsing
    layout = cms_layouts(:all_included_tags)
    tags = CmsTag::parse_tags(layout.content)
    assert_equal 4, tags.size
  end
  
  def test_block_tag
    layout = cms_layouts(:all_included_tags)
    tag = layout.tags.select{|t| t.tag_signature == 'cms_block:test_block:string'}.first
    assert tag
    assert_equal 'cms_block', tag.tag_type
    assert_equal 'test_block', tag.label
    assert_equal 'string', tag.format
    
    assert_equal 1, tag.class.render_priority
    
    # TODO: content pulling
  end
  
  def test_page_block_tag
    layout = cms_layouts(:all_included_tags)
    tag = layout.tags.select{|t| t.tag_signature == 'cms_page_block:test_page_block:string'}.first
    assert tag
    assert_equal 'cms_page_block', tag.tag_type
    assert_equal 'test_page_block', tag.label
    assert_equal 'string', tag.format
    
    assert_equal 1, tag.class.render_priority
    
    # TODO: content pulling
  end
  
  def test_snippet_tag
    layout = cms_layouts(:all_included_tags)
    tag = layout.tags.select{|t| t.tag_signature == 'cms_snippet:test_snippet'}.first
    assert tag
    assert_equal 'cms_snippet', tag.tag_type
    assert_equal 'test_snippet', tag.label
    
    assert_equal 2, tag.class.render_priority
    
    # TODO: content pulling
  end
  
  def test_partial_tag
    layout = cms_layouts(:all_included_tags)
    tag = layout.tags.select{|t| t.tag_signature == 'cms_partial:content/test_partial'}.first
    assert tag
    assert_equal 'cms_partial', tag.tag_type
    assert_equal 'content/test_partial', tag.label
    
    assert_equal 3, tag.class.render_priority
    assert_equal "<%= render :partial => 'content/test_partial' %>", tag.content
  end
  
  def test_tag_uniqueness
    layout = cms_layouts(:identical_tags)
    assert_equal 3, layout.tags.size
    tag_signatures = %w(cms_block:my_block_1:text cms_block:my_block_2:integer cms_block:my_block_3:boolean)
    layout.tags.each do |tag|
      assert tag_signatures.member?(tag.tag_signature)
      assert_equal tag.class, CmsTag::Block
    end
  end
  
end
