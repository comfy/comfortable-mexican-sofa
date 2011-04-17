require File.expand_path('../../test_helper', File.dirname(__FILE__))

class PageStringTest < ActiveSupport::TestCase
  
  def test_initialize_tag
    assert tag = ComfortableMexicanSofa::Tag::PageString.initialize_tag(
      cms_pages(:default), '{{ cms:page:content:string }}'
    )
    assert_equal 'content', tag.label
    assert tag = ComfortableMexicanSofa::Tag::PageString.initialize_tag(
      cms_pages(:default), '{{cms:page:content:string}}'
    )
    assert_equal 'content', tag.label
    assert tag = ComfortableMexicanSofa::Tag::PageString.initialize_tag(
      cms_pages(:default), '{{cms:page:dash-content:string}}'
    )
    assert_equal 'dash-content', tag.label
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
    assert tag.content.blank?
    tag.content = 'test_content'
    assert_equal 'test_content', tag.content
    assert_equal 'test_content', tag.render
  end
  
end