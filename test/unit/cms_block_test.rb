require File.expand_path('../test_helper', File.dirname(__FILE__))

class CmsBlockTest < ActiveSupport::TestCase
  
  def test_fixtures_validity
    CmsBlock.all.each do |block|
      assert block.valid?, block.errors.full_messages.to_s
    end
  end
  
  def test_new_via_page_nested_attributes
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
            :content  => 'test_content'
          }
        ]
      )
      assert_equal 1, page.cms_blocks.count
      block = page.cms_blocks.first
      assert_equal 'test_block', block.label
      assert_equal 'test_content', block.content
    end
  end
  
  def test_initialize_or_find
    tag = CmsTag::PageText.initialize_or_find(cms_pages(:default), :default_field_text)
    assert_equal 'default_field_text', tag.label
    assert_equal 'default_field_text_content', tag.content
    
    tag = CmsTag::PageText.initialize_or_find(cms_pages(:default), :new_block)
    assert_equal 'new_block', tag.label
    assert tag.content.blank?
  end
  
end
