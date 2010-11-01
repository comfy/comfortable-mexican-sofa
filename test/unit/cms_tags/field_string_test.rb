require File.expand_path('../../test_helper', File.dirname(__FILE__))

class FieldStringTest < ActiveSupport::TestCase
  
  def test_initialize_tag
    [
      '{{ cms:field:content:string }}',
      '{{cms:field:content:string}}',
      '{{cms:field:content}}'
    ].each do |tag_signature|
      assert tag = CmsTag::FieldString.initialize_tag(cms_pages(:default), tag_signature)
      assert_equal 'content', tag.label
    end
  end
  
  def test_initialize_tag_failure
    [
      '{{cms:field:content:not_string}}',
      '{{cms:not_field:content}}',
      '{not_a_tag}'
    ].each do |tag_signature|
      assert_nil CmsTag::FieldString.initialize_tag(cms_pages(:default), tag_signature)
    end
  end
  
  def test_content_and_render
    tag = CmsTag::FieldString.initialize_tag(cms_pages(:default), '{{cms:field:content}}')
    assert tag.content.blank?
    tag.content = 'test_content'
    assert_equal 'test_content', tag.content
    assert_equal 'test_content', tag.read_attribute(:content_string)
    assert_equal '', tag.render
  end
  
end