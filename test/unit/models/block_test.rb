require File.expand_path('../../test_helper', File.dirname(__FILE__))

class CmsBlockTest < ActiveSupport::TestCase
  
  def test_fixtures_validity
    Cms::Block.all.each do |block|
      assert block.valid?, block.errors.full_messages.to_s
    end
  end
  
  def test_tag
    block = cms_blocks(:default_page_text)
    assert block.page.tags(true).collect(&:identifier).member?('page_text_default_page_text')
    assert_equal 'page_text_default_page_text', block.tag.identifier
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
  
  def test_new_via_page_nested_attributes_as_hash
    assert_difference ['Cms::Page.count', 'Cms::Block.count'] do
      page = Cms::Page.create!(
        :site       => cms_sites(:default),
        :layout     => cms_layouts(:default),
        :label      => 'test page',
        :slug       => 'test_page',
        :parent_id  => cms_pages(:default).id,
        :blocks_attributes => {
          '0' => {
            :label    => 'default_page_text',
            :content  => 'test_content'
          }
        }
      )
      assert_equal 1, page.blocks.count
      block = page.blocks.first
      assert_equal 'default_page_text', block.label
      assert_equal 'test_content', block.content
    end
  end
  
  def test_new_via_nested_attributes_with_files
    assert_difference ['Cms::Page.count', 'Cms::Block.count'] do
      assert_difference 'Cms::File.count', 2 do
        page = Cms::Page.create!(
          :site       => cms_sites(:default),
          :layout     => cms_layouts(:default),
          :label      => 'test page',
          :slug       => 'test_page',
          :parent_id  => cms_pages(:default).id,
          :blocks_attributes => [
            {
              :label    => 'default_page_text',
              :content  => [fixture_file_upload('files/valid_image.jpg'), fixture_file_upload('files/invalid_file.gif')] 
            }
          ]
        )
        assert_equal 1, page.blocks.count
        block = page.blocks.first
        assert_equal 'default_page_text', block.label
        assert_equal nil, block.content
        assert_equal 2, block.files.count
      end
    end
  end
  
end
