require_relative '../../test_helper'

class PageIntegerTagTest < ActiveSupport::TestCase
  
  def test_initialize_tag
    assert tag = ComfortableMexicanSofa::Tag::PageInteger.initialize_tag(
      cms_pages(:default), '{{ cms:page:content:integer }}'
    )
    assert_equal 'content', tag.identifier
    assert_nil tag.namespace
    assert tag = ComfortableMexicanSofa::Tag::PageInteger.initialize_tag(
      cms_pages(:default), '{{cms:page:content:integer}}'
    )
    assert_equal 'content', tag.identifier
    assert tag = ComfortableMexicanSofa::Tag::PageInteger.initialize_tag(
      cms_pages(:default), '{{cms:page:dash-content:integer}}'
    )
    assert_equal 'dash-content', tag.identifier
    assert tag = ComfortableMexicanSofa::Tag::PageInteger.initialize_tag(
      cms_pages(:default), '{{cms:page:namespace.content:integer}}'
    )
    assert_equal 'namespace.content', tag.identifier
    assert_equal 'namespace', tag.namespace
  end
  
  def test_initialize_tag_failure
    [
      '{{cms:page:content:not_integer}}',
      '{{cms:page:content}}',
      '{{cms:not_page:content}}',
      '{not_a_tag}'
    ].each do |tag_signature|
      assert_nil ComfortableMexicanSofa::Tag::PageInteger.initialize_tag(
        cms_pages(:default), tag_signature
      )
    end
  end
  
  def test_content_and_render
    tag = ComfortableMexicanSofa::Tag::PageInteger.initialize_tag(
      cms_pages(:default), '{{cms:page:content:integer}}'
    )
    assert tag.block.content.blank?
    tag.block.content = '5'
    assert_equal '5', tag.content
    assert_equal '5', tag.render
  end
  
end