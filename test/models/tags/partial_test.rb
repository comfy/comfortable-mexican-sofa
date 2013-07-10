require_relative '../../test_helper'

class PartialTagTest < ActiveSupport::TestCase
  
  def test_initialize_tag
    assert tag = ComfortableMexicanSofa::Tag::Partial.initialize_tag(
      cms_pages(:default), '{{ cms:partial:partial_name }}'
    )
    assert_equal 'partial_name', tag.identifier
    assert tag = ComfortableMexicanSofa::Tag::Partial.initialize_tag(
      cms_pages(:default), '{{cms:partial:path/to/partial}}'
    )
    assert_equal 'path/to/partial', tag.identifier
    assert tag = ComfortableMexicanSofa::Tag::Partial.initialize_tag(
      cms_pages(:default), '{{cms:partial:path/to/dashed-partial}}'
    )
    assert_equal 'path/to/dashed-partial', tag.identifier
  end
  
  def test_initialize_tag_with_parameters
    assert tag = ComfortableMexicanSofa::Tag::Partial.initialize_tag(
      cms_pages(:default), '{{cms:partial:path/to/partial:param1:param2}}'
    )
    assert tag.identifier = 'path/to/partial'
    assert tag.params = 'param1:param2'
  end
  
  def test_initialize_tag_failure
    [
      '{{cms:partial}}',
      '{{cms:not_partial:label}}',
      '{not_a_tag}'
    ].each do |tag_signature|
      assert_nil ComfortableMexicanSofa::Tag::Partial.initialize_tag(
        cms_pages(:default), tag_signature
      )
    end
  end
  
  def test_content_and_render
    tag = ComfortableMexicanSofa::Tag::Partial.initialize_tag(
      cms_pages(:default), '{{cms:partial:path/to/partial}}'
    )
    assert_equal "<%= render :partial => 'path/to/partial' %>", tag.content
    assert_equal "<%= render :partial => 'path/to/partial' %>", tag.render
    
    tag = ComfortableMexicanSofa::Tag::Partial.initialize_tag(
      cms_pages(:default), '{{cms:partial:path/to/partial:param1}}'
    )
    assert_equal "<%= render :partial => 'path/to/partial', :locals => {:param_1 => 'param1'} %>", tag.content
    assert_equal "<%= render :partial => 'path/to/partial', :locals => {:param_1 => 'param1'} %>", tag.render
    
    tag = ComfortableMexicanSofa::Tag::Partial.initialize_tag(
      cms_pages(:default), '{{cms:partial:path/to/partial:param1:param2}}'
    )
    assert_equal "<%= render :partial => 'path/to/partial', :locals => {:param_1 => 'param1', :param_2 => 'param2'} %>", tag.content
    assert_equal "<%= render :partial => 'path/to/partial', :locals => {:param_1 => 'param1', :param_2 => 'param2'} %>", tag.render
  end
  
  def test_whitelisted_paths
    ComfortableMexicanSofa.config.allowed_partials = ['safe/path']
    
    tag = ComfortableMexicanSofa::Tag::Partial.initialize_tag(
      cms_pages(:default), '{{cms:partial:safe/path}}'
    )
    assert_equal "<%= render :partial => 'safe/path' %>", tag.content
    assert_equal "<%= render :partial => 'safe/path' %>", tag.render
    
    tag = ComfortableMexicanSofa::Tag::Partial.initialize_tag(
      cms_pages(:default), '{{cms:partial:unsafe/path}}'
    )
    assert_equal "<%= render :partial => 'unsafe/path' %>", tag.content
    assert_equal nil, tag.render
  end
  
end