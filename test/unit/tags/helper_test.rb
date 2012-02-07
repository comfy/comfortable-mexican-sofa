require File.expand_path('../../test_helper', File.dirname(__FILE__))

class HelperTagTest < ActiveSupport::TestCase

  def test_initialize_tag
    assert tag = ComfortableMexicanSofa::Tag::Helper.initialize_tag(
      cms_pages(:default), '{{ cms:helper:example_helper_url }}'
    )
    assert_equal 'example_helper_url', tag.identifier
  end
  
  def test_initialize_tag_with_parameters
    assert tag = ComfortableMexicanSofa::Tag::Helper.initialize_tag(
      cms_pages(:default), '{{ cms:helper:example_helper_url:param1:param2 }}'
    )
    assert_equal 'example_helper_url', tag.identifier
    assert_equal ['param1', 'param2'], tag.params
  end

  def test_initialize_tag_with_complex_parameters
    assert tag = ComfortableMexicanSofa::Tag::Helper.initialize_tag(
      cms_pages(:default), '{{ cms:helper:example_helper_url:param1:"param:2" }}'
    )
    assert_equal 'example_helper_url', tag.identifier
    assert_equal ['param1', 'param:2'], tag.params
  end
  
  def test_initialize_tag_failure
    [
      '{{cms:helper}}',
      '{{cms:not_helper:example_helper_url}}',
      '{not_a_tag}'
    ].each do |tag_signature|
      assert_nil ComfortableMexicanSofa::Tag::Helper.initialize_tag(
        cms_pages(:default), tag_signature
      )
    end
  end
  
  def test_content_and_render
    tag = ComfortableMexicanSofa::Tag::Helper.initialize_tag(
      cms_pages(:default), '{{cms:helper:example_helper_url}}'
    )
    assert_equal "<%= example_helper_url() %>", tag.content
    assert_equal "<%= example_helper_url() %>", tag.render
    
    tag = ComfortableMexicanSofa::Tag::Helper.initialize_tag(
      cms_pages(:default), '{{cms:helper:example_helper_url:param1:param2}}'
    )
    assert_equal "<%= example_helper_url('param1', 'param2') %>", tag.content
    assert_equal "<%= example_helper_url('param1', 'param2') %>", tag.render
  end

  def test_no_eval_in_default_config
    tag = ComfortableMexicanSofa::Tag::Helper.initialize_tag(
      cms_pages(:default), '{{cms:helper:eval:"User.first.inspect"}}'
    )

    assert_equal "", tag.content
    assert_equal "", tag.render
  end

  def test_using_allowed_helpers_regexp
    ComfortableMexicanSofa.configuration.allowed_helpers = /^puts_info/

    tag = ComfortableMexicanSofa::Tag::Helper.initialize_tag(
      cms_pages(:default), '{{cms:helper:puts_info}}'
    )
    assert_equal "<%= puts_info() %>", tag.content, "should allow helper in allowed_helper"

    tag = ComfortableMexicanSofa::Tag::Helper.initialize_tag(
      cms_pages(:default), '{{cms:helper:translate}}'
    )
    assert_equal "", tag.content, "should only allow helpers in allowed_helper"

    ComfortableMexicanSofa.configuration.allowed_helpers = nil
  end

  def test_helper_name_sanitization
    tag = ComfortableMexicanSofa::Tag::Helper.initialize_tag(
      cms_pages(:default), '{{cms:helper:current_user.class.delete_all}}'
    )
    assert_equal "<%= current_user('.class.delete_all') %>", tag.content, "no dots in helper name"

    tag = ComfortableMexicanSofa::Tag::Helper.initialize_tag(
      cms_pages(:default), '{{cms:helper:current-eval:"User.first.inspect"}}'
    )
    assert_equal "<%= current('-eval', 'User.first.inspect') %>", tag.content, "no minus signs in helper name"
  end

  def test_escaping_of_parameters
    tag = ComfortableMexicanSofa::Tag::Helper.initialize_tag(
      cms_pages(:default), '{{cms:helper:h:"\'+User.first.inspect+\'"}}'
    )

    assert_equal %{<%= h('\\'+User.first.inspect+\\'') %>}, tag.content
    assert_equal %{<%= h('\\'+User.first.inspect+\\'') %>}, tag.render
  end

end
