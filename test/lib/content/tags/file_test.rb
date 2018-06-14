# frozen_string_literal: true

require_relative "../../../test_helper"

class ContentTagsFileTest < ActiveSupport::TestCase

  delegate :rails_blob_path, to: "Rails.application.routes.url_helpers"

  setup do
    @page = comfy_cms_pages(:default)
  end

  # -- Tests -------------------------------------------------------------------

  def test_init
    tag = ComfortableMexicanSofa::Content::Tag::File.new(context: @page, params: ["test"])
    assert_equal "test",  tag.identifier
    assert_equal "url",   tag.as
  end

  def test_init_with_params
    tag = ComfortableMexicanSofa::Content::Tag::File.new(
      context: @page,
      params: ["test", {
        "as"      => "image",
        "resize"  => "100x100",
        "gravity" => "center",
        "crop"    => "100x100+0+0"
      }]
    )
    assert_equal "test",  tag.identifier
    assert_equal "image", tag.as
    assert_equal ({
      "resize"  => "100x100",
      "gravity" => "center",
      "crop"    => "100x100+0+0"
    }), tag.variant_attrs
  end

  def test_content
    frag = comfy_cms_fragments(:file)
    tag = ComfortableMexicanSofa::Content::Tag::File.new(context: @page, params: [frag.identifier])
    assert_equal rails_blob_path(frag.attachments.first, only_path: true), tag.content
  end

  def test_content_as_link
    frag = comfy_cms_fragments(:file)
    tag = ComfortableMexicanSofa::Content::Tag::File.new(
      context: @page,
      params: [frag.identifier, { "as" => "link" }]
    )
    out = "<a href='#{rails_blob_path(frag.attachments.first, only_path: true)}' target='_blank'>fragment.jpg</a>"
    assert_equal out, tag.content
  end

  def test_content_as_image
    frag = comfy_cms_fragments(:file)
    tag = ComfortableMexicanSofa::Content::Tag::File.new(
      context: @page,
      params: [frag.identifier, { "as" => "image" }]
    )
    out = "<img src='#{rails_blob_path(frag.attachments.first, only_path: true)}' alt='fragment.jpg'/>"
    assert_equal out, tag.content
  end

  def test_content_as_image_with_variant
    frag = comfy_cms_fragments(:file)
    tag = ComfortableMexicanSofa::Content::Tag::File.new(
      context: @page,
      params: [frag.identifier, { "as" => "image", "resize" => "50x50" }]
    )
    out = "<img src='#{rails_blob_path(frag.attachments.first, only_path: true)}' alt='fragment.jpg'/>"
    assert_equal out, tag.content
  end

  def test_content_with_no_attachment
    tag = ComfortableMexicanSofa::Content::Tag::File.new(context: @page, params: ["test"])
    assert_equal "", tag.content
  end

end
