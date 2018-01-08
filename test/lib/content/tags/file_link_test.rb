require_relative "../../../test_helper"

class ContentTagsFileLinkTest < ActiveSupport::TestCase

  delegate :rails_blob_path, to: "Rails.application.routes.url_helpers"

  setup do
    @page = comfy_cms_pages(:default)
    @file = comfy_cms_files(:default)
  end

  # -- Tests -------------------------------------------------------------------

  def test_init
    tag = ComfortableMexicanSofa::Content::Tag::FileLink.new(@page, "123")
    assert_equal "123", tag.identifier
    assert_equal "url", tag.as
  end

  def test_init_with_params
    string = "123, as: image, resize: 100x100, gravity: center, crop: '100x100+0+0'"
    tag = ComfortableMexicanSofa::Content::Tag::FileLink.new(@page, string)
    assert_equal "123", tag.identifier
    assert_equal "image", tag.as
    assert_equal ({
      "resize"  => "100x100",
      "gravity" => "center",
      "crop"    => "100x100+0+0"
    }), tag.variant_attrs
  end

  def test_init_without_identifier
    message = "Missing identifier for file link tag"
    assert_exception_raised ComfortableMexicanSofa::Content::Tag::Error, message do
      ComfortableMexicanSofa::Content::Tag::FileLink.new(@page, "")
    end
  end

  def test_file
    tag = ComfortableMexicanSofa::Content::Tag::FileLink.new(@page, @file.id)
    assert tag.file.is_a?(Comfy::Cms::File)

    tag = ComfortableMexicanSofa::Content::Tag::FileLink.new(@page, "invalid")
    assert_nil tag.file
  end

  def test_content
    tag = ComfortableMexicanSofa::Content::Tag::FileLink.new(@page, @file.id)
    out = rails_blob_path(tag.file.attachment, only_path: true)
    assert_equal out, tag.content
    assert_equal out, tag.render
  end

  def test_content_as_link
    tag = ComfortableMexicanSofa::Content::Tag::FileLink.new(@page, "#{@file.id}, as: link")
    url = rails_blob_path(tag.file.attachment, only_path: true)
    out = "<a href='#{url}' target='_blank'>default file</a>"
    assert_equal out, tag.content
    assert_equal out, tag.render
  end

  def test_content_as_image
    tag = ComfortableMexicanSofa::Content::Tag::FileLink.new(@page, "#{@file.id}, as: image")
    url = rails_blob_path(tag.file.attachment, only_path: true)
    out = "<img src='#{url}' alt='default file'/>"
    assert_equal out, tag.content
    assert_equal out, tag.render
  end

  def test_content_when_not_found
    tag = ComfortableMexicanSofa::Content::Tag::FileLink.new(@page, "invalid")
    assert_equal "", tag.content
    assert_equal "", tag.render
  end

end
