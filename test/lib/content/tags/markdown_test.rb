# frozen_string_literal: true

require_relative "../../../test_helper"

class ContentTagsMarkdownTest < ActiveSupport::TestCase

  setup do
    @page = comfy_cms_pages(:default)
  end

  def test_init
    tag = ComfortableMexicanSofa::Content::Tag::Markdown.new(context: @page, params: ["test"])
    assert_equal "test", tag.identifier
  end

  def test_content
    frag = comfy_cms_fragments(:default)
    tag = ComfortableMexicanSofa::Content::Tag::Markdown.new(context: @page, params: [frag.identifier])
    assert_equal frag,          tag.fragment
    assert_equal frag.content,  tag.content
  end

  def test_render
    frag = comfy_cms_fragments(:default)
    frag.update_column(:content, "**test**")
    tag = ComfortableMexicanSofa::Content::Tag::Markdown.new(context: @page, params: [frag.identifier])
    assert_equal "<p><strong>test</strong></p>\n", tag.render
  end

  def test_render_unrenderable
    frag = comfy_cms_fragments(:default)
    tag = ComfortableMexicanSofa::Content::Tag::Markdown.new(
      context: @page,
      params: [frag.identifier, { "render" => "false" }]
    )
    assert_equal "", tag.render
  end

end
