# frozen_string_literal: true

require_relative "../../../test_helper"

class ContentTagsSnippetTest < ActiveSupport::TestCase

  setup do
    @page = comfy_cms_pages(:default)
  end

  def test_init
    tag = ComfortableMexicanSofa::Content::Tag::Snippet.new(context: @page, params: ["default"])
    assert_equal "default", tag.identifier
    assert_equal comfy_cms_snippets(:default), tag.snippet
  end

  def test_init_without_identifier
    message = "Missing identifier for snippet tag"
    assert_exception_raised ComfortableMexicanSofa::Content::Tag::Error, message do
      ComfortableMexicanSofa::Content::Tag::Snippet.new(context: @page)
    end
  end

  def test_snippet_new_record
    tag = ComfortableMexicanSofa::Content::Tag::Snippet.new(context: @page, params: ["new"])
    assert tag.snippet.new_record?
  end

  def test_content
    tag = ComfortableMexicanSofa::Content::Tag::Snippet.new(context: @page, params: ["default"])
    assert_equal "snippet content", tag.content
  end

  def test_content_new_record
    tag = ComfortableMexicanSofa::Content::Tag::Snippet.new(context: @page, params: ["new"])
    assert_nil tag.content
  end

end
