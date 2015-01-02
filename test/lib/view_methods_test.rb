require_relative '../test_helper'

class ViewMethodsTest < ActionView::TestCase

  include Comfy::CmsHelper

  module TestViewHelpers
    def hello
      'hello'
    end
  end
  ActionView::Base.send :include, TestViewHelpers

  def setup
    @cms_site = comfy_cms_sites(:default)
    @cms_page = comfy_cms_pages(:default)
    comfy_cms_blocks(:default_page_text).update_column(:content, 'default_page_text_content')
  end

  def test_cms_block_content
    assert_equal 'default_page_text_content', cms_block_content(:default_page_text)
    assert_equal 'default_page_text_content', cms_block_content(:default_page_text, @cms_page)
    assert_equal 'default_field_text_content', cms_block_content(:default_field_text)
  end

  def test_cms_block_content_render
    assert_equal 'default_field_text_content', cms_block_content_render(:default_field_text)
  end

  def test_cms_block_render
    assert_equal 'default_page_text_content', cms_block_render(:default_page_text)
    assert_equal '', cms_block_render(:default_field_text)
  end

  def test_cms_block_with_erb
    comfy_cms_blocks(:default_page_text).update_column(:content, '<%= 1 + 1 %>')
    assert_equal '<%= 1 + 1 %>', cms_block_content(:default_page_text)
    assert_equal '&lt;%= 1 + 1 %&gt;', cms_block_render(:default_page_text)
  end

  def test_cms_block_with_tags
    comfy_cms_blocks(:default_page_text).update_column(:content, '{{ cms:helper:hello }}')
    assert_equal '{{ cms:helper:hello }}', cms_block_content(:default_page_text)
    assert_equal 'hello', cms_block_render(:default_page_text)
  end

  def test_cms_block_missing
    assert_equal '', cms_block_content(:invalid)
    assert_equal '', cms_block_content(:invalid, @cms_page)
    assert_equal '', cms_block_content(:invalid)
    assert_equal '', cms_block_content(:default_page_text, @invalid)

    assert_equal '', cms_block_render(:invalid)
  end

  def test_cms_block_with_files
    @cms_page.layout.update_column(:content, '{{cms:page_files:files}}')
    @cms_page.update_attributes!(
      :blocks_attributes => [
        {
          :identifier => 'files',
          :content    => [
            fixture_file_upload('files/image.jpg', "image/jpeg"),
            fixture_file_upload('files/image.gif', "image/gif")
          ]
        }
      ]
    )

    block = @cms_page.blocks.find_by(:identifier => 'files')
    assert_equal block.files, cms_block_content(:files)
    assert_equal 2, block.files.count

    assert_equal block.files.collect{|file| file.file.url}.join(', '), cms_block_render(:files)
  end

  def test_cms_snippet_content
    assert_equal 'default_snippet_content', cms_snippet_content(:default)
    assert_equal 'default_snippet_content', cms_snippet_content(:default, @cms_site)
  end

  def test_cms_snippet_content_with_site_loading
    @cms_site = nil
    assert_equal 'default_snippet_content', cms_snippet_content(:default)
  end

  def test_cms_snippet_missing
    assert_equal '', cms_snippet_content(:invalid)
    assert_equal '', cms_snippet_render(:invalid)
  end

  def test_cms_snippet_render_with_no_site
    @cms_site = nil
    assert_equal '', cms_snippet_render(:default)
  end

  def test_cms_snippet_render
    assert_equal 'default_snippet_content', cms_snippet_render(:default)
  end

  def test_cms_snippet_with_erb
    comfy_cms_snippets(:default).update_column(:content, '<%= 1 + 1 %>')
    assert_equal '<%= 1 + 1 %>', cms_snippet_content(:default)
    assert_equal '&lt;%= 1 + 1 %&gt;', cms_snippet_render(:default)
  end

  def test_cms_snippet_render_with_tags
    comfy_cms_snippets(:default).update_column(:content, '{{ cms:helper:hello }}')
    assert_equal 'hello', cms_snippet_render(:default)
  end

  def test_cms_snippet_content_with_block
    assert_difference 'Comfy::Cms::Snippet.count' do
      content = cms_snippet_content(:new_snippet) do
        'new content'
      end
      assert_equal 'new content', content
      snippet = Comfy::Cms::Snippet.last
      assert_equal 'new content', snippet.content
      assert_equal @cms_site, snippet.site
    end
  end

end
