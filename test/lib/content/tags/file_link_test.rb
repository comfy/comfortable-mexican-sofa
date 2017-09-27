require_relative '../../../test_helper'

class ContentTagsFileLinkTest < ActiveSupport::TestCase

  setup do
    @page = comfy_cms_pages(:default)
  end

  def test_init
    tag = ComfortableMexicanSofa::Content::Tag::FileLink.new(@page, "default")
    assert_equal "default", tag.identifier
    assert_equal "url", tag.as
    assert_equal "default", tag.label
  end

  def test_init_with_params
    tag = ComfortableMexicanSofa::Content::Tag::FileLink.new(@page, "default, as: image, label: test")
    assert_equal "default", tag.identifier
    assert_equal "image", tag.as
    assert_equal "test", tag.label
  end

  def test_init_without_identifier
    message = "Missing identifier for file link tag"
    assert_exception_raised ComfortableMexicanSofa::Content::Tag::Error, message do
      ComfortableMexicanSofa::Content::Tag::FileLink.new(@page, "")
    end
  end

  def test_file
    tag = ComfortableMexicanSofa::Content::Tag::FileLink.new(@page, "default.jpg")
    assert tag.file.is_a?(Comfy::Cms::File)
  end

  def test_content_and_render
    tag = ComfortableMexicanSofa::Content::Tag::FileLink.new(@page, "default.jpg")
    out = tag.file.file.url
    assert_equal out, tag.content
    assert_equal out, tag.render
  end

  def test_content_and_render_as_link
    tag = ComfortableMexicanSofa::Content::Tag::FileLink.new(@page, "default.jpg, as: link, label: test")
    out = "<a href='#{tag.file.file.url}' target='_blank'>test</a>"
    assert_equal out, tag.content
    assert_equal out, tag.render
  end

  def test_content_and_render_as_image
    tag = ComfortableMexicanSofa::Content::Tag::FileLink.new(@page, "default.jpg, as: image, label: test")
    out = "<img src='#{tag.file.file.url}' alt='test' />"
    assert_equal out, tag.content
    assert_equal out, tag.render
  end

  def test_content_and_render_not_found
    tag = ComfortableMexicanSofa::Content::Tag::FileLink.new(@page, "invalid.jpg")
    assert_equal "", tag.content
    assert_equal "", tag.render
  end
end
