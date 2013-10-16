require_relative '../../test_helper'

class FieldIntegerTagTest < ActiveSupport::TestCase
  
  def test_initialize_tag
    assert tag = ComfortableMexicanSofa::Tag::FieldInteger.initialize_tag(
      cms_pages(:default), '{{ cms:field:content:integer }}'
    )
    assert_equal 'content', tag.identifier
    assert_nil tag.namespace
    assert tag = ComfortableMexicanSofa::Tag::FieldInteger.initialize_tag(
      cms_pages(:default), '{{cms:field:content:integer}}'
    )
    assert_equal 'content', tag.identifier
    assert tag = ComfortableMexicanSofa::Tag::FieldInteger.initialize_tag(
      cms_pages(:default), '{{cms:field:dash-content:integer}}'
    )
    assert_equal 'dash-content', tag.identifier
    assert tag = ComfortableMexicanSofa::Tag::FieldInteger.initialize_tag(
      cms_pages(:default), '{{cms:field:namespace.content:integer}}'
    )
    assert_equal 'namespace.content', tag.identifier
    assert_equal 'namespace', tag.namespace
  end
  
  def test_initialize_tag_failure
    [
      '{{cms:field:content:not_integer}}',
      '{{cms:field:content}}',
      '{{cms:not_field:content}}',
      '{not_a_tag}'
    ].each do |tag_signature|
      assert_nil ComfortableMexicanSofa::Tag::FieldInteger.initialize_tag(
        cms_pages(:default), tag_signature
      )
    end
  end
  
  def test_content_and_render
    tag = ComfortableMexicanSofa::Tag::FieldInteger.initialize_tag(
      cms_pages(:default), '{{cms:field:content:integer}}'
    )
    assert tag.block.content.blank?
    tag.block.content = '5'
    assert_equal '5', tag.content
    assert_equal '', tag.render
  end
  
end