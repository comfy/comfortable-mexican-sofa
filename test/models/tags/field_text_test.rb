require_relative '../../test_helper'

class FieldTextTagTest < ActiveSupport::TestCase
  
  def test_initialize_tag
    assert tag = ComfortableMexicanSofa::Tag::FieldText.initialize_tag(
      cms_pages(:default), '{{ cms:field:content:text }}'
    )
    assert_equal 'content', tag.identifier
    assert_nil tag.namespace
    assert tag = ComfortableMexicanSofa::Tag::FieldText.initialize_tag(
      cms_pages(:default), '{{cms:field:content:text}}'
    )
    assert_equal 'content', tag.identifier
    assert tag = ComfortableMexicanSofa::Tag::FieldText.initialize_tag(
      cms_pages(:default), '{{cms:field:dash-content:text}}'
    )
    assert_equal 'dash-content', tag.identifier
    assert tag = ComfortableMexicanSofa::Tag::FieldText.initialize_tag(
      cms_pages(:default), '{{cms:field:namespace.content:text}}'
    )
    assert_equal 'namespace.content', tag.identifier
    assert_equal 'namespace', tag.namespace
  end
  
  def test_initialize_tag_failure
    [
      '{{cms:field:content:not_text}}',
      '{{cms:not_field:content:text}}',
      '{not_a_tag}'
    ].each do |tag_signature|
      assert_nil ComfortableMexicanSofa::Tag::FieldText.initialize_tag(
        cms_pages(:default), tag_signature
      )
    end
  end
  
  def test_content_and_render
    tag = ComfortableMexicanSofa::Tag::FieldText.initialize_tag(
      cms_pages(:default), '{{cms:field:content:text}}'
    )
    assert tag.block.content.blank?
    tag.block.content = 'test_content'
    assert_equal 'test_content', tag.content
    assert_equal '', tag.render
  end
  
end