require File.dirname(__FILE__) + '/../../test_helper'

class HelperTest < ActiveSupport::TestCase
  
  def test_initialize_tag
    %w(
      <cms:helper:method_name/>
    ).each do |tag_signature|
      assert tag = CmsTag::Helper.initialize_tag(cms_pages(:default), tag_signature)
    end
  end
  
  def test_initialize_tag_failure
    %w(
      <cms:helper>
      <cms:not_helper:method_name/>
      not_a_tag
    ).each do |tag_signature|
      assert_nil CmsTag::Helper.initialize_tag(cms_pages(:default), tag_signature)
    end
  end
  
  def test_content_and_render
    tag = CmsTag::Helper.initialize_tag(cms_pages(:default), "<cms:helper:method_name>")
    assert_equal "<%= method_name %>", tag.content
    assert_equal "<%= method_name %>", tag.render
  end
  
end