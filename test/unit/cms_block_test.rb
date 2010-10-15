require File.dirname(__FILE__) + '/../test_helper'

class CmsBlockTest < ActiveSupport::TestCase
  
  def test_fixtures_validity
    CmsBlock.all.each do |block|
      assert block.valid?, block.errors.full_messages
    end
  end
  
  def test_new_with_cast
    block = CmsBlock.new(:label => 'test_block', :content => 'test_content', :type => 'CmsTag::PageText')
    assert_equal 'CmsTag::PageText', block.class.name
    assert_equal 'test_block', block.label
    assert_equal 'test_content', block.content
    
    assert_difference 'CmsBlock.count' do
      block.cms_page = cms_pages(:default)
      block.save!
    end
  end
  
  def test_new_with_cast_via_page_nested_attributes
    assert_difference ['CmsPage.count', 'CmsBlock.count'] do
      page = CmsPage.create!(
        :cms_site   => cms_sites(:default),
        :cms_layout => cms_layouts(:default),
        :label      => 'test page',
        :slug       => 'test_page',
        :parent_id  => cms_pages(:default).id,
        :cms_blocks_attributes => [
          {
            :label    => 'test_block',
            :content  => 'test_content',
            :type     => 'CmsTag::PageText'
          }
        ]
      )
      assert_equal 1, page.cms_blocks.count
      block = page.cms_blocks.first
      assert_equal 'CmsTag::PageText', block.class.name
      assert_equal 'test_block', block.label
      assert_equal 'test_content', block.content
    end
  end
  
  def test_initialize_or_find
    block = CmsBlock.initialize_or_find(cms_pages(:default), :default_field_text)
    assert !block.new_record?
    assert_equal 'default_field_text', block.label
    assert_equal 'CmsTag::FieldText', block.class.name
    assert_equal 'default_field_text_content', block.content
    
    block = CmsTag::PageText.initialize_or_find(cms_pages(:default), :new_block)
    assert block.new_record?
    assert_equal 'new_block', block.label
    assert_equal 'CmsTag::PageText', block.class.name
    assert block.content.blank?
  end
  
end
