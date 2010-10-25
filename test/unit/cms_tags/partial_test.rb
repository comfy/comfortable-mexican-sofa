require File.dirname(__FILE__) + '/../../test_helper'

class PartialTest < ActiveSupport::TestCase
  
  def test_initialize_tag
    %w(
      <cms:partial:partial_name/>
      <cms:partial:path/to/partial>
    ).each do |tag_signature|
      assert tag = CmsTag::Partial.initialize_tag(cms_pages(:default), tag_signature)
    end
  end
  
  def test_initialize_tag_with_parameters
    assert tag = CmsTag::Partial.initialize_tag(cms_pages(:default), '<cms:partial:path/to/partial:param1:param2/>')
    assert tag.label = 'path/to/partial'
    assert tag.params = 'param1:param2'
  end
  
  def test_initialize_tag_failure
    %w(
      <cms:partial>
      <cms:not_partial:label/>
      not_a_tag
    ).each do |tag_signature|
      assert_nil CmsTag::Partial.initialize_tag(cms_pages(:default), tag_signature)
    end
  end
  
  def test_content_and_render
    tag = CmsTag::Partial.initialize_tag(cms_pages(:default), "<cms:partial:path/to/patial>")
    assert_equal "<%= render :partial => 'path/to/patial' %>", tag.content
    assert_equal "<%= render :partial => 'path/to/patial' %>", tag.render
    
    tag = CmsTag::Partial.initialize_tag(cms_pages(:default), '<cms:partial:path/to/partial:param1:param2/>')
    assert_equal "<%= render :partial => 'path/to/partial', :locals => {:param_1 => 'param1', :param_2 => 'param2'} %>", tag.content
    assert_equal "<%= render :partial => 'path/to/partial', :locals => {:param_1 => 'param1', :param_2 => 'param2'} %>", tag.render
  end
  
end