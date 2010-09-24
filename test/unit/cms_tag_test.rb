require File.dirname(__FILE__) + '/../test_helper'

class CmsTagTest < ActiveSupport::TestCase
  
  def test_content_for_existing_page
    page = cms_pages(:default)
    assert page.cms_tags.blank?
    assert_equal rendered_content_formatter(
      '
      layout_content_a
      default_page_text_content_a
      default_snippet_content
      default_page_text_content_b
      layout_content_b
      default_snippet_content
      layout_content_c'
    ), page.content
    
    assert_equal 4, page.cms_tags.size
    assert_equal 'cms_tag/field_text_default_field_text', page.cms_tags[0].identifier
    assert_equal 'cms_tag/page_text_default_page_text', page.cms_tags[1].identifier
    assert_equal 'cms_tag/snippet_default', page.cms_tags[2].identifier
    assert_equal page.cms_tags[1], page.cms_tags[2].parent
    assert_equal 'cms_tag/snippet_default', page.cms_tags[3].identifier
  end
  
  def test_content_for_new_page
    page = CmsPage.new
    assert page.cms_blocks.blank?
    assert page.cms_tags.blank?
    assert_equal '', page.content
    assert page.cms_tags.blank?
  end
  
  def test_content_for_new_page_with_layout
    page = CmsPage.new(:cms_layout => cms_layouts(:default))
    assert page.cms_blocks.blank?
    assert page.cms_tags.blank?
    assert_equal rendered_content_formatter(
      '
      layout_content_a
      
      layout_content_b
      default_snippet_content
      layout_content_c'
    ), page.content
    
    assert_equal 3, page.cms_tags.size
    assert_equal 'cms_tag/field_text_default_field_text', page.cms_tags[0].identifier
    assert_equal 'cms_tag/page_text_default_page_text', page.cms_tags[1].identifier
    assert_equal 'cms_tag/snippet_default', page.cms_tags[2].identifier
  end
  
  def test_content_for_new_page_with_initilized_cms_blocks
    page = CmsPage.new(:cms_layout => cms_layouts(:default))
    assert page.cms_blocks.blank?
    assert page.cms_tags.blank?
    page.cms_blocks_attributes = [
      {
        :label    => 'default_field_text',
        :content  => 'new_default_field_content',
        :type     => 'CmsTag::FieldText'
      },
      {
        :label    => 'default_page_text',
        :content  => "new_default_page_text_content\n<cms:snippet:default>",
        :type     => 'CmsTag::PageText'
      },
      {
        :label    => 'bogus_field_that_never_will_get_rendered',
        :content  => 'some_content_that_doesnot_matter',
        :type     => 'CmsTag::PageText'
      }
    ]
    assert_equal 3, page.cms_blocks.size
    
    assert_equal rendered_content_formatter(
      '
      layout_content_a
      new_default_page_text_content
      default_snippet_content
      layout_content_b
      default_snippet_content
      layout_content_c'
    ), page.content
    
    assert_equal 4, page.cms_tags.size
    assert_equal 'cms_tag/field_text_default_field_text', page.cms_tags[0].identifier
    assert_equal 'cms_tag/page_text_default_page_text', page.cms_tags[1].identifier
    assert_equal 'cms_tag/snippet_default', page.cms_tags[2].identifier
    assert_equal page.cms_tags[1], page.cms_tags[2].parent
    assert_equal 'cms_tag/snippet_default', page.cms_tags[3].identifier
  end
  
  def test_content_with_repeated_tags
    page = cms_pages(:default)
    page.cms_layout.content << "\n<cms:page:default_page_text:text>"
    page.cms_layout.save!
    
    assert_equal rendered_content_formatter(
      '
      layout_content_a
      default_page_text_content_a
      default_snippet_content
      default_page_text_content_b
      layout_content_b
      default_snippet_content
      layout_content_c
      default_page_text_content_a
      default_snippet_content
      default_page_text_content_b'
    ), page.content
    
    assert_equal 6, page.cms_tags.size
    assert_equal 'cms_tag/field_text_default_field_text', page.cms_tags[0].identifier
    assert_equal 'cms_tag/page_text_default_page_text', page.cms_tags[1].identifier
    assert_equal 'cms_tag/snippet_default', page.cms_tags[2].identifier
    assert_equal page.cms_tags[1], page.cms_tags[2].parent
    assert_equal 'cms_tag/snippet_default', page.cms_tags[3].identifier
    assert_equal 'cms_tag/page_text_default_page_text', page.cms_tags[4].identifier
    assert_equal 'cms_tag/snippet_default', page.cms_tags[5].identifier
    assert_equal page.cms_tags[4], page.cms_tags[5].parent
  end
  
  def test_content_with_shallow_cyclical_tags
    page = cms_pages(:default)
    snippet = cms_snippets(:default)
    snippet.update_attribute(:content, "infinite <cms:snippet:default> loop")
    assert_equal rendered_content_formatter(
      '
      layout_content_a
      default_page_text_content_a
      infinite  loop
      default_page_text_content_b
      layout_content_b
      infinite  loop
      layout_content_c'
    ), page.content
    
  end
  
  def test_content_with_deep_cyclical_tags
    page = cms_pages(:default)
    snippet = cms_snippets(:default)
    snippet.update_attribute(:content, "infinite <cms:page:default> loop")
    assert_equal rendered_content_formatter(
      '
      layout_content_a
      default_page_text_content_a
      infinite  loop
      default_page_text_content_b
      layout_content_b
      infinite  loop
      layout_content_c'
    ), page.content
  end
  
  def test_tag_equality
    tag_1 = CmsTag::PageText.new(:label => 'new_text', :content => 'content')
    tag_2 = CmsTag::FieldText.new(:label => 'new_text', :content => 'content')
    tag_3 = CmsTag::PageText.new(:label => 'new_text', :content => 'other content')
    
    assert_not_equal tag_1, tag_2
    assert_equal tag_1, tag_3
  end
end
