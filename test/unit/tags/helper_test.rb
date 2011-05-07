require File.expand_path('../../test_helper', File.dirname(__FILE__))

class HelperTest < ActiveSupport::TestCase
  
  def test_initialize_tag
    assert tag = ComfortableMexicanSofa::Tag::Helper.initialize_tag(
      cms_pages(:default), '{{ cms:helper:method_name }}'
    )
    assert_equal 'method_name', tag.label
    assert tag = ComfortableMexicanSofa::Tag::Helper.initialize_tag(
      cms_pages(:default), '{{ cms:helper:method-name }}'
    )
    assert_equal 'method-name', tag.label
  end
  
  def test_initialize_tag_with_parameters
    assert tag = ComfortableMexicanSofa::Tag::Helper.initialize_tag(
      cms_pages(:default), '{{ cms:helper:method_name:param1:param2 }}'
    )
    assert tag.label = 'method_name'
    assert tag.params = 'param1:param2'
  end
  
  def test_initialize_tag_failure
    [
      '{{cms:helper}}',
      '{{cms:not_helper:method_name}}',
      '{not_a_tag}'
    ].each do |tag_signature|
      assert_nil ComfortableMexicanSofa::Tag::Helper.initialize_tag(
        cms_pages(:default), tag_signature
      )
    end
  end
  
  def test_content_and_render
    tag = ComfortableMexicanSofa::Tag::Helper.initialize_tag(
      cms_pages(:default), '{{cms:helper:method_name}}'
    )
    assert_equal "<%= method_name() %>", tag.content
    assert_equal "<%= method_name() %>", tag.render
    
    tag = ComfortableMexicanSofa::Tag::Helper.initialize_tag(
      cms_pages(:default), '{{cms:helper:method_name:param1:param2}}'
    )
    assert_equal "<%= method_name('param1', 'param2') %>", tag.content
    assert_equal "<%= method_name('param1', 'param2') %>", tag.render
  end
  
end