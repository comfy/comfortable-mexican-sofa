require File.expand_path('../../test_helper', File.dirname(__FILE__))

class FieldDateTimeTagTest < ActiveSupport::TestCase
  
  def test_initialize_tag
    assert tag = ComfortableMexicanSofa::Tag::FieldDateTime.initialize_tag(
      cms_pages(:default), '{{ cms:field:content:datetime }}'
    )
    assert_equal 'content', tag.label
    assert tag = ComfortableMexicanSofa::Tag::FieldDateTime.initialize_tag(
      cms_pages(:default), '{{cms:field:content:datetime}}'
    )
    assert_equal 'content', tag.label
    assert tag = ComfortableMexicanSofa::Tag::FieldDateTime.initialize_tag(
      cms_pages(:default), '{{cms:field:dash-content:datetime}}'
    )
    assert_equal 'dash-content', tag.label
  end
  
  def test_initialize_tag_failure
    [
      '{{cms:field:content:not_datetime}}',
      '{{cms:field:content}}',
      '{{cms:not_field:content}}',
      '{not_a_tag}'
    ].each do |tag_signature|
      assert_nil ComfortableMexicanSofa::Tag::FieldDateTime.initialize_tag(
        cms_pages(:default), tag_signature
      )
    end
  end
  
  def test_content_and_render
    tag = ComfortableMexicanSofa::Tag::FieldDateTime.initialize_tag(
      cms_pages(:default), '{{cms:field:content:datetime}}'
    )
    assert tag.content.blank?
    time = 2.days.ago
    tag.content = time
    assert_equal time, tag.content
    assert_equal '', tag.render
  end
  
end