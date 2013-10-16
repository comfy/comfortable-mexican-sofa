require_relative '../../test_helper'

class PageMarkdownTagTest < ActiveSupport::TestCase
  
  def test_initialize_tag
    assert tag = ComfortableMexicanSofa::Tag::PageMarkdown.initialize_tag(
      cms_pages(:default), '{{ cms:page:content:markdown }}'
    )
    assert_equal 'content', tag.identifier
    assert_nil tag.namespace
    assert tag = ComfortableMexicanSofa::Tag::PageMarkdown.initialize_tag(
      cms_pages(:default), '{{cms:page:content:markdown}}'
    )
    assert_equal 'content', tag.identifier
    assert tag = ComfortableMexicanSofa::Tag::PageMarkdown.initialize_tag(
      cms_pages(:default), '{{cms:page:dash-content:markdown}}'
    )
    assert_equal 'dash-content', tag.identifier
    assert tag = ComfortableMexicanSofa::Tag::PageMarkdown.initialize_tag(
      cms_pages(:default), '{{cms:page:namespace.content:markdown}}'
    )
    assert_equal 'namespace.content', tag.identifier
    assert_equal 'namespace', tag.namespace
  end
  
  def test_initialize_tag_failure
    [
      '{{cms:page:content:not_markdown}}',
      '{{cms:page:content}}',
      '{{cms:not_page:content}}',
      '{not_a_tag}'
    ].each do |tag_signature|
      assert_nil ComfortableMexicanSofa::Tag::PageMarkdown.initialize_tag(
        cms_pages(:default), tag_signature
      )
    end
  end
  
  def test_content_and_render
    tag = ComfortableMexicanSofa::Tag::PageMarkdown.initialize_tag(
      cms_pages(:default), '{{cms:page:content:markdown}}'
    )
    assert tag.block.content.blank?
    tag.block.content = '_test_content_'
    assert_equal '_test_content_', tag.content
    assert_equal "<p><em>test_content</em></p>\n", tag.render
  end
end