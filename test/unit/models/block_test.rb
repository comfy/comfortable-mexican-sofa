require File.expand_path('../../test_helper', File.dirname(__FILE__))

class BlockTest < ActiveSupport::TestCase
  
  def test_fixtures_validity
    Cms::Block.all.each do |block|
      assert block.valid?, block.errors.full_messages.to_s
    end
  end
  
  def test_new_via_page_nested_attributes
    assert_difference ['Cms::Page.count', 'Cms::Block.count'] do
      page = Cms::Page.create!(
        :site       => cms_sites(:default),
        :layout     => cms_layouts(:default),
        :label      => 'test page',
        :slug       => 'test_page',
        :parent_id  => cms_pages(:default).id,
        :blocks_attributes => [
          {
            :label    => 'default_page_text',
            :content  => 'test_content'
          }
        ]
      )
      assert_equal 1, page.blocks.count
      block = page.blocks.first
      assert_equal 'default_page_text', block.label
      assert_equal 'test_content', block.content
    end
  end
  
end
