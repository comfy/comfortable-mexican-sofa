require_relative '../test_helper'

class CmsBlockTest < ActiveSupport::TestCase

  def test_fixtures_validity
    Comfy::Cms::Block.all.each do |block|
      assert block.valid?, block.errors.full_messages.to_s
    end
  end

  def test_tag
    block = comfy_cms_blocks(:default_page_text)
    assert block.blockable.tags(true).collect(&:id).member?('page_text_default_page_text')
    assert_equal 'page_text_default_page_text', block.tag.id
  end

  def test_content_assignment
    block = Comfy::Cms::Block.new

    block.content = 'test'
    assert_equal 'test', block.content

    block.content = 12345
    assert_equal 12345, block.content

    block.content = [1, 2, 3]
    assert_equal [1, 2, 3], block.content
  end

  def test_content_assignment_with_files
    block = Comfy::Cms::Block.new

    block.content = fixture_file_upload('files/image.jpg', 'image/jpeg')
    assert_equal nil, block.content
    assert_equal 1, block.temp_files.size
  end

  def test_creation_via_page_nested_attributes
    assert_difference ['Comfy::Cms::Page.count', 'Comfy::Cms::Block.count'] do
      page = comfy_cms_sites(:default).pages.create!(
        :layout     => comfy_cms_layouts(:default),
        :label      => 'test page',
        :slug       => 'test_page',
        :parent_id  => comfy_cms_pages(:default).id,
        :blocks_attributes => [
          {
            :identifier => 'default_page_text',
            :content    => 'test_content'
          }
        ]
      )
      assert_equal 1, page.blocks.count
      block = page.blocks.first
      assert_equal 'default_page_text', block.identifier
      assert_equal 'test_content', block.content
    end
  end

  def test_creation_via_page_nested_attributes_as_hash
    assert_difference ['Comfy::Cms::Page.count', 'Comfy::Cms::Block.count'] do
      page = comfy_cms_sites(:default).pages.create!(
        :layout     => comfy_cms_layouts(:default),
        :label      => 'test page',
        :slug       => 'test_page',
        :parent_id  => comfy_cms_pages(:default).id,
        :blocks_attributes => {
          '0' => {
            :identifier => 'default_page_text',
            :content    => 'test_content'
          }
        }
      )
      assert_equal 1, page.blocks.count
      block = page.blocks.first
      assert_equal 'default_page_text', block.identifier
      assert_equal 'test_content', block.content
    end
  end

  def test_creation_via_page_nested_attributes_as_hash_with_duplicates
    assert_difference ['Comfy::Cms::Page.count', 'Comfy::Cms::Block.count'] do
      page = comfy_cms_sites(:default).pages.create!(
        :layout     => comfy_cms_layouts(:default),
        :label      => 'test page',
        :slug       => 'test_page',
        :parent_id  => comfy_cms_pages(:default).id,
        :blocks_attributes => {
          '0' => {
            :identifier => 'default_page_text',
            :content    => 'test_content'
          },
          '1' => {
            :identifier => 'default_page_text',
            :content    => 'test_content'
          }
        }
      )
      assert_equal 1, page.blocks.count
      block = page.blocks.first
      assert_equal 'default_page_text', block.identifier
      assert_equal 'test_content', block.content
    end
  end

  def test_creation_and_update_via_nested_attributes_with_file
    layout = comfy_cms_layouts(:default)
    layout.update_columns(:content => '{{cms:page_file:file}}')

    page = nil
    assert_difference ['Comfy::Cms::Page.count', 'Comfy::Cms::Block.count', 'Comfy::Cms::File.count'] do
      page = comfy_cms_sites(:default).pages.create!(
        :layout     => layout,
        :label      => 'test page',
        :slug       => 'test_page',
        :parent_id  => comfy_cms_pages(:default).id,
        :blocks_attributes => [
          { :identifier => 'file',
            :content    => [
              fixture_file_upload('files/image.jpg', 'image/jpeg'),
              fixture_file_upload('files/document.pdf', 'application/pdf')
            ]
          }
        ]
      )
      assert_equal 1, page.blocks.count
      block = page.blocks.first
      assert_equal 'file', block.identifier
      assert_equal nil, block.content
      assert_equal 1, block.files.count
      assert_equal 'image.jpg', block.files.first.file_file_name

      page.reload
      assert_equal block.files.first.file.url, page.content_cache
    end

    assert_no_difference ['Comfy::Cms::Block.count', 'Comfy::Cms::File.count'] do
      page.update_attributes!(
        :blocks_attributes => [
          { :identifier => 'file',
            :content    => fixture_file_upload('files/document.pdf', "application/pdf") }
        ]
      )
      page.reload
      block = page.blocks.first
      assert_equal 1, block.files.count
      assert_equal 'document.pdf', block.files.first.file_file_name
      assert_equal block.files.first.file.url, page.content_cache
    end
  end

  def test_creation_and_update_via_nested_attributes_with_files
    layout = comfy_cms_layouts(:default)
    layout.update_columns(:content => '{{cms:page_files:files}}')

    page = nil
    assert_difference ['Comfy::Cms::Page.count', 'Comfy::Cms::Block.count'] do
      assert_difference 'Comfy::Cms::File.count', 2 do
        page = comfy_cms_sites(:default).pages.create!(
          :layout             => layout,
          :label              => 'test page',
          :slug               => 'test_page',
          :parent_id          => comfy_cms_pages(:default).id,
          :blocks_attributes  => [
            { :identifier => 'files',
              :content    => [
                fixture_file_upload('files/image.jpg', 'image/jpeg'),
                fixture_file_upload('files/image.gif', 'image/gif')
              ]
            }
          ]
        )

        assert_equal 1, page.blocks.count
        block = page.blocks.first
        assert_equal 'files', block.identifier
        assert_equal nil, block.content
        assert_equal 2, block.files.count
        assert_equal ['image.jpg', 'image.gif'], block.files.collect(&:file_file_name)
      end
    end

    assert_no_difference 'Comfy::Cms::Block.count' do
      assert_difference 'Comfy::Cms::File.count', 2 do
        page.update_attributes!(
          :blocks_attributes => [
            { :identifier => 'files',
              :content    => [
                fixture_file_upload('files/document.pdf', 'application/pdf'),
                fixture_file_upload('files/image.gif', 'image/gif')
              ]
            }
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

  def test_creation_via_nested_attributes_with_file
    layout = comfy_cms_layouts(:default)
    layout.update_columns(:content => '{{cms:page:header}}{{cms:page_file:file}}{{cms:page:footer}}')

    assert_difference 'Comfy::Cms::Page.count' do
      assert_difference 'Comfy::Cms::Block.count', 3 do
        page = comfy_cms_sites(:default).pages.create!(
          :layout     => layout,
          :label      => 'test page',
          :slug       => 'test_page',
          :parent_id  => comfy_cms_pages(:default).id,
          :blocks_attributes => {
            '0' => {
              :identifier => 'header',
              :content    => 'header content'
            },
            '1' => {
              :identifier => 'file',
              :content    => fixture_file_upload('files/document.pdf', 'application/pdf')
            },
            '2' => {
              :identifier => 'footer',
              :content    => 'footer content'
            }
          }
        )
      end
    end
  end

end
