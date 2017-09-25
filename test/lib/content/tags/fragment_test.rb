require_relative '../../../test_helper'

class ContentTagsFragmentTest < ActiveSupport::TestCase

  setup do
    @page = comfy_cms_pages(:default)
  end

  def test_init
    tag = ComfortableMexicanSofa::Content::Tag::Fragment.new(@page, "content")
    assert_equal @page,     tag.context
    assert_equal "content", tag.identifier
    assert_equal "wysiwyg", tag.format
    assert_equal true,      tag.renderable
  end

  def test_init_with_params
    tag = ComfortableMexicanSofa::Content::Tag::Fragment.new(@page, "content, format: text, render: false")
    assert_equal "text", tag.format
    assert_equal false,  tag.renderable
  end

  def test_init_without_identifier
    message = "Missing identifier for fragment tag"
    assert_exception_raised ComfortableMexicanSofa::Content::Tag::Error, message do
      ComfortableMexicanSofa::Content::Tag::Fragment.new(@page, "")
    end
  end

  def test_fragment
    tag = ComfortableMexicanSofa::Content::Tag::Fragment.new(@page, "default")
    assert_equal comfy_cms_blocks(:default), tag.fragment
  end

  def test_fragment_new_record
    tag = ComfortableMexicanSofa::Content::Tag::Fragment.new(@page, "new")
    fragment = tag.fragment
    assert fragment.is_a?(Comfy::Cms::Block)
    assert fragment.new_record?
  end

  def test_content
    tag = ComfortableMexicanSofa::Content::Tag::Fragment.new(@page, "default")
    assert_equal "content", tag.content
  end

  def test_content_new_record
    tag = ComfortableMexicanSofa::Content::Tag::Fragment.new(@page, "new")
    assert_nil tag.content
  end

  def test_render
    tag = ComfortableMexicanSofa::Content::Tag::Fragment.new(@page, "default")
    assert_equal "content", tag.render
  end

  def test_render_with_markdown
    comfy_cms_blocks(:default).update_column(:content, "_markdown_")
    tag = ComfortableMexicanSofa::Content::Tag::Fragment.new(@page, "default, format: markdown")
    assert_equal "<p><em>markdown</em></p>\n", tag.render
  end

  def test_render_when_not_renderable
    tag = ComfortableMexicanSofa::Content::Tag::Fragment.new(@page, "default, render: false")
    assert_equal "", tag.render
  end

end