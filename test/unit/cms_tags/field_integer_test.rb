require File.expand_path('../../test_helper', File.dirname(__FILE__))

class FieldIntegerTest < ActiveSupport::TestCase
  
  def test_initialize_tag
    [
      '{{ cms:field:content:integer }}',
      '{{cms:field:content:integer}}'
    ].each do |tag_signature|
      assert tag = CmsTag::FieldInteger.initialize_tag(cms_pages(:default), tag_signature)
      assert_equal 'content', tag.label
    end
  end
  
  def test_initialize_tag_failure
    [
      '{{cms:field:content:not_integer}}',
      '{{cms:field:content}}',
      '{{cms:not_field:content}}',
      '{not_a_tag}'
    ].each do |tag_signature|
      assert_nil CmsTag::FieldInteger.initialize_tag(cms_pages(:default), tag_signature)
    end
  end
  
  def test_content_and_render
    tag = CmsTag::FieldInteger.initialize_tag(cms_pages(:default), '{{cms:field:content:integer}}')
    assert tag.content.blank?
    tag.content = '5'
    assert_equal '5', tag.content
    assert_equal '', tag.render
  end
  
end