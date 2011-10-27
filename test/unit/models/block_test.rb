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
  
  def test_creation_via_page_nested_attributes
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
  
  def test_creation_via_page_nested_attributes_as_hash
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
  
  def test_creation_via_page_nested_attributes_as_hash_with_duplicates
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
          },
          '1' => {
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
  
  def test_creation_and_update_via_nested_attributes_with_file
    layout = cms_layouts(:default)
    layout.update_attribute(:content, '{{cms:page_file:file}}')
    
    page = nil
    assert_difference ['Cms::Page.count', 'Cms::Block.count', 'Cms::File.count'] do
      page = Cms::Page.create!(
        :site       => cms_sites(:default),
        :layout     => layout,
        :label      => 'test page',
        :slug       => 'test_page',
        :parent_id  => cms_pages(:default).id,
        :blocks_attributes => [
          { :label    => 'file',
            :content  => [fixture_file_upload('files/image.jpg'), fixture_file_upload('files/document.pdf')] }
        ]
      )
      assert_equal 1, page.blocks.count
      block = page.blocks.first
      assert_equal 'file', block.label
      assert_equal nil, block.content
      assert_equal 1, block.files.count
      assert_equal 'image.jpg', block.files.first.file_file_name
      
      page.reload
      assert_equal block.files.first.file.url, page.content
    end
    
    assert_no_difference ['Cms::Block.count', 'Cms::File.count'] do
      page.update_attributes!(
        :blocks_attributes => [
          { :label    => 'file',
            :content  => fixture_file_upload('files/document.pdf') }
        ]
      )
      page.reload
      block = page.blocks.first
      assert_equal 1, block.files.count
      assert_equal 'document.pdf', block.files.first.file_file_name
      assert_equal block.files.first.file.url, page.content
    end
  end
  
  def test_creation_and_update_via_nested_attributes_with_files
    layout = cms_layouts(:default)
    layout.update_attribute(:content, '{{cms:page_files:files}}')
    
    page = nil
    assert_difference ['Cms::Page.count', 'Cms::Block.count'] do
      assert_difference 'Cms::File.count', 2 do
        page = Cms::Page.create!(
          :site       => cms_sites(:default),
          :layout     => layout,
          :label      => 'test page',
          :slug       => 'test_page',
          :parent_id  => cms_pages(:default).id,
          :blocks_attributes => [
            { :label    => 'files',
              :content  => [fixture_file_upload('files/image.jpg'), fixture_file_upload('files/image.gif')] }
          ]
        )
        assert_equal 1, page.blocks.count
        block = page.blocks.first
        assert_equal 'files', block.label
        assert_equal nil, block.content
        assert_equal 2, block.files.count
        assert_equal ['image.jpg', 'image.gif'], block.files.collect(&:file_file_name)
      end
    end
    
    assert_no_difference 'Cms::Block.count' do
      assert_difference 'Cms::File.count', 2 do
        page.update_attributes!(
          :blocks_attributes => [
            { :label    => 'files',
              :content  => [fixture_file_upload('files/document.pdf'), fixture_file_upload('files/image.gif')] }
          ]
        )
        page.reload
        block = page.blocks.first
        assert_equal 4, block.files.count
        assert_equal ['image.jpg', 'image.gif', 'document.pdf', 'image.gif'], 
          block.files.collect(&:file_file_name)
      end
    end
  end
  
end
