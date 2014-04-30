require_relative '../../test_helper'

class FieldEditableTagTest < ActiveSupport::TestCase

  def test_initialize_tag
    assert tag = ComfortableMexicanSofa::Tag::FieldEditable.initialize_tag(
      cms_pages(:default), '{{ cms:field:content:editable }}'
    )
    assert_equal 'content', tag.identifier
    assert_nil tag.namespace
    assert tag = ComfortableMexicanSofa::Tag::FieldEditable.initialize_tag(
      cms_pages(:default), '{{cms:field:content:editable}}'
    )
    assert_equal 'content', tag.identifier
    assert tag = ComfortableMexicanSofa::Tag::FieldEditable.initialize_tag(
      cms_pages(:default), '{{cms:field:dash-content:editable}}'
    )
    assert_equal 'dash-content', tag.identifier
    assert tag = ComfortableMexicanSofa::Tag::FieldEditable.initialize_tag(
      cms_pages(:default), '{{cms:field:namespace.content:editable}}'
    )
    assert_equal 'namespace.content', tag.identifier
    assert_equal 'namespace', tag.namespace
  end

  def test_initialize_tag_failure
    [
      '{{cms:field:content:not_editable}}',
      '{{cms:not_field:content:editable}}',
      '{not_a_tag}'
    ].each do |tag_signature|
      assert_nil ComfortableMexicanSofa::Tag::FieldEditable.initialize_tag(
        cms_pages(:default), tag_signature
      )
    end
  end

  def test_content_and_render
    tag = ComfortableMexicanSofa::Tag::FieldEditable.initialize_tag(
      cms_pages(:default), '{{cms:field:content:editable}}'
    )
    assert tag.block.content.blank?
    tag.block.content = 'test_content'
    assert_equal 'test_content', tag.content
    assert_equal '', tag.render
  end
end