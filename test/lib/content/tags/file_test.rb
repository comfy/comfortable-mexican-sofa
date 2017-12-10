require_relative "../../../test_helper"

class ContentTagsFileTest < ActiveSupport::TestCase

  setup do
    @page = comfy_cms_pages(:default)
  end

  def url_for(attachment)
    ApplicationController.render(
      inline: "<%= url_for(@attachment) %>",
      assigns: { attachment: attachment }
    )
  end

  # -- Tests -------------------------------------------------------------------

  def test_init
    tag = ComfortableMexicanSofa::Content::Tag::File.new(@page, "test")
    assert_equal "test",  tag.identifier
    assert_equal "url",   tag.as
  end

  def test_init_with_params
    string = "test, as: image, resize: 100x100, gravity: center, crop: '100x100+0+0'"
    tag = ComfortableMexicanSofa::Content::Tag::File.new(@page, string)
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
    tag = ComfortableMexicanSofa::Content::Tag::File.new(@page, frag.identifier)
    assert_equal url_for(frag.attachments.first), tag.content
  end

  def test_content_as_link
    frag = comfy_cms_fragments(:file)
    tag = ComfortableMexicanSofa::Content::Tag::File.new(@page, "#{frag.identifier}, as: link")
    out = "<a href='#{url_for(frag.attachments.first)}' target='_blank'>fragment.jpg</a>"
    assert_equal out, tag.content
  end

  def test_content_as_image
    frag = comfy_cms_fragments(:file)
    tag = ComfortableMexicanSofa::Content::Tag::File.new(@page, "#{frag.identifier}, as: image")
    out = "<img src='#{url_for(frag.attachments.first)}' alt='fragment.jpg'/>"
    assert_equal out, tag.content
  end

  def test_content_with_no_attachment
    tag = ComfortableMexicanSofa::Content::Tag::File.new(@page, "test")
    assert_equal "", tag.content
  end
end
