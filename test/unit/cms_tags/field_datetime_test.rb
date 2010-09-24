require File.dirname(__FILE__) + '/../../test_helper'

class FieldDateTimeTest < ActiveSupport::TestCase
  
  def test_initialize_tag
    %w(
      <cms:field:content:datetime/>
      <cms:field:content:datetime>
    ).each do |tag_signature|
      assert tag = CmsTag::FieldDateTime.initialize_tag(cms_pages(:default), tag_signature)
      assert_equal 'content', tag.label
    end
  end
  
  def test_initialize_tag_failure
    %w(
      <cms:field:content:not_datetime/>
      <cms:field:content/>
      <cms:not_field:content/>
      not_a_tag
    ).each do |tag_signature|
      assert_nil CmsTag::FieldDateTime.initialize_tag(cms_pages(:default), tag_signature)
    end
  end
  
  def test_content_and_render
    tag = CmsTag::FieldDateTime.initialize_tag(cms_pages(:default), "<cms:field:content:datetime>")
    assert tag.content.blank?
    time = 2.days.ago
    tag.content = time
    assert_equal time, tag.content
    assert_equal time, tag.read_attribute(:content_datetime)
    assert_equal '', tag.render
  end
  
end