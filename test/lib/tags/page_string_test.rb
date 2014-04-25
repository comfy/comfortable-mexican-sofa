require_relative '../../test_helper'

class PageStringTagTest < ActiveSupport::TestCase
  
  def test_initialize_tag
    assert tag = ComfortableMexicanSofa::Tag::PageString.initialize_tag(
      cms_pages(:default), '{{ cms:page:content:string }}'
    )
    assert_equal 'content', tag.identifier
    assert_nil tag.namespace
    assert tag = ComfortableMexicanSofa::Tag::PageString.initialize_tag(
      cms_pages(:default), '{{cms:page:content:string}}'
    )
    assert_equal 'content', tag.identifier
    assert tag = ComfortableMexicanSofa::Tag::PageString.initialize_tag(
      cms_pages(:default), '{{cms:page:dash-content:string}}'
    )
    assert_equal 'dash-content', tag.identifier
    assert tag = ComfortableMexicanSofa::Tag::PageString.initialize_tag(
      cms_pages(:default), '{{cms:page:namespace.content:string}}'
    )
    assert_equal 'namespace.content', tag.identifier
    assert_equal 'namespace', tag.namespace
  end
  
  def test_initialize_tag_failure
    [
      '{{cms:page:content:not_string}}',
      '{{cms:page:content}}',
      '{{cms:not_page:content}}',
      '{not_a_tag}'
    ].each do |tag_signature|
      assert_nil ComfortableMexicanSofa::Tag::PageString.initialize_tag(
        cms_pages(:default), tag_signature
      )
    end
  end
  
  def test_content_and_render
    tag = ComfortableMexicanSofa::Tag::PageString.initialize_tag(
      cms_pages(:default), '{{cms:page:content:string}}'
    )
    assert tag.block.content.blank?
    tag.block.content = 'test_content'
    assert_equal 'test_content', tag.content
    assert_equal 'test_content', tag.render
  end
  
end