require File.expand_path('../../test_helper', File.dirname(__FILE__))

class FieldTextTest < ActiveSupport::TestCase
  
  def test_initialize_tag
    [
      '{{ cms:field:content:text }}',
      '{{cms:field:content:text}}'
    ].each do |tag_signature|
      assert tag = CmsTag::FieldText.initialize_tag(cms_pages(:default), tag_signature)
      assert_equal 'content', tag.label
    end
  end
  
  def test_initialize_tag_failure
    [
      '{{cms:field:content:not_text}}',
      '{{cms:not_field:content:text}}',
      '{not_a_tag}'
    ].each do |tag_signature|
      assert_nil CmsTag::FieldText.initialize_tag(cms_pages(:default), tag_signature)
    end
  end
  
  def test_content_and_render
    tag = CmsTag::FieldText.initialize_tag(cms_pages(:default), '{{cms:field:content:text}}')
    assert tag.content.blank?
    tag.content = 'test_content'
    assert_equal 'test_content', tag.content
    assert_equal 'test_content', tag.read_attribute(:content_text)
    assert_equal '', tag.render
  end
  
end