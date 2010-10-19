require File.dirname(__FILE__) + '/../../test_helper'

class SnippetTest < ActiveSupport::TestCase
  
  def test_initialize_tag
    %w(
      <cms:snippet:label/>
      <cms:snippet:label>
    ).each do |tag_signature|
      assert tag = CmsTag::Snippet.initialize_tag(cms_pages(:default), tag_signature)
      assert_equal 'label', tag.slug
    end
  end
  
  def test_initialize_tag_failure
    %w(
      <cms:snippet>
      <cms:not_snippet:label/>
      not_a_tag
    ).each do |tag_signature|
      assert_nil CmsTag::Snippet.initialize_tag(cms_pages(:default), tag_signature)
    end
  end
  
  def test_content_and_render
    tag = CmsTag::Snippet.initialize_tag(cms_pages(:default), "<cms:snippet:default>")
    assert_equal 'default_snippet_content', tag.content
    assert_equal 'default_snippet_content', tag.render
    
    tag = CmsTag::Snippet.initialize_tag(cms_pages(:default), "<cms:snippet:doesnot_exist>")
    assert_equal nil, tag.content
    assert_equal '', tag.render
  end
end