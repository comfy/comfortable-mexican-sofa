# frozen_string_literal: true

require_relative "../../../test_helper"

class ContentTagsPageFileLinkTest < ActiveSupport::TestCase

  delegate :rails_blob_path, to: "Rails.application.routes.url_helpers"

  setup do
    @page = comfy_cms_pages(:default)
    @file = comfy_cms_files(:default)
  end

  # -- Tests -------------------------------------------------------------------

  def test_init
    tag = ComfortableMexicanSofa::Content::Tag::PageFileLink.new(context: @page, params: ["123"])
    assert_equal "123", tag.identifier
    assert_equal "url", tag.as
  end

  def test_init_with_params
    tag = ComfortableMexicanSofa::Content::Tag::PageFileLink.new(
      context: @page,
      params: [
        "123", {
          "as" => "image",
          "resize"  => "100x100",
          "gravity" => "center",
          "crop"    => "100x100+0+0"
        }
      ]
    )
    assert_equal "123", tag.identifier
    assert_equal "image", tag.as
    assert_equal ({
      "resize" => "100x100",
      "gravity" => "center",
      "crop"    => "100x100+0+0"
    }), tag.variant_attrs
  end

  def test_init_without_identifier
    message = "Missing identifier for page file link tag"
    assert_exception_raised ComfortableMexicanSofa::Content::Tag::Error, message do
      ComfortableMexicanSofa::Content::Tag::PageFileLink.new(context: @page)
    end
  end

  def test_content
    fragment = comfy_cms_fragments(:file)
    tag = ComfortableMexicanSofa::Content::Tag::PageFileLink.new(context: @page, params: [fragment.identifier])
    out = rails_blob_path(tag.file, only_path: true)
    assert_equal out, tag.content
    assert_equal out, tag.render
  end

  def test_content_when_not_found
    tag = ComfortableMexicanSofa::Content::Tag::PageFileLink.new(context: @page, params: ["invalid"])
    assert_equal "", tag.content
    assert_equal "", tag.render
  end

end
