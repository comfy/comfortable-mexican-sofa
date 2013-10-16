require_relative '../../test_helper'

class HelperTagTest < ActiveSupport::TestCase
  
  def test_initialize_tag
    assert tag = ComfortableMexicanSofa::Tag::Helper.initialize_tag(
      cms_pages(:default), '{{ cms:helper:method_name }}'
    )
    assert_equal 'method_name', tag.identifier
    assert tag = ComfortableMexicanSofa::Tag::Helper.initialize_tag(
      cms_pages(:default), '{{ cms:helper:method-name }}'
    )
    assert_equal 'method-name', tag.identifier
  end
  
  def test_initialize_tag_with_parameters
    assert tag = ComfortableMexicanSofa::Tag::Helper.initialize_tag(
      cms_pages(:default), '{{ cms:helper:method_name:param1:param2 }}'
    )
    assert_equal 'method_name', tag.identifier
    assert_equal ['param1', 'param2'], tag.params
  end

  def test_initialize_tag_with_complex_parameters
    assert tag = ComfortableMexicanSofa::Tag::Helper.initialize_tag(
      cms_pages(:default), '{{ cms:helper:method_name:param1:"param:2" }}'
    )
    assert_equal 'method_name', tag.identifier
    assert_equal ['param1', 'param:2'], tag.params

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
  
  def test_blacklisted_methods
    ComfortableMexicanSofa::Tag::Helper::BLACKLIST.each do |method|
      tag = ComfortableMexicanSofa::Tag::Helper.initialize_tag(
        cms_pages(:default), "{{ cms:helper:#{method}:Rails.env }}"
      )
      assert_equal "<%= #{method}('Rails.env') %>", tag.content
      assert_equal nil, tag.render
    end
  end
  
  def test_whitelisted_methods
    ComfortableMexicanSofa.config.allowed_helpers = [:tester, :eval]
    ComfortableMexicanSofa.config.allowed_helpers.each do |method|
      tag = ComfortableMexicanSofa::Tag::Helper.initialize_tag(
        cms_pages(:default), "{{ cms:helper:#{method}:Rails.env }}"
      )
      assert_equal "<%= #{method}('Rails.env') %>", tag.content
      assert_equal "<%= #{method}('Rails.env') %>", tag.render
    end
    
    tag = ComfortableMexicanSofa::Tag::Helper.initialize_tag(
      cms_pages(:default), "{{ cms:helper:invalid:Rails.env }}"
    )
    assert_equal "<%= invalid('Rails.env') %>", tag.content
    assert_equal nil, tag.render
  end
  
end
