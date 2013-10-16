require_relative '../../test_helper'

class TemplateTagTest < ActiveSupport::TestCase

  def test_initialize_tag
    assert tag = ComfortableMexicanSofa::Tag::Template.initialize_tag(
      cms_pages(:default), '{{ cms:template:template_name }}'
    )
    assert_equal 'template_name', tag.identifier
    assert tag = ComfortableMexicanSofa::Tag::Template.initialize_tag(
      cms_pages(:default), '{{cms:template:path/to/template}}'
    )
    assert_equal 'path/to/template', tag.identifier
    assert tag = ComfortableMexicanSofa::Tag::Template.initialize_tag(
      cms_pages(:default), '{{cms:template:path/to/dashed-template}}'
    )
    assert_equal 'path/to/dashed-template', tag.identifier
  end

  def test_initialize_tag_failure
    [
      '{{cms:template}}',
      '{{cms:not_template:label}}',
      '{not_a_tag}'
    ].each do |tag_signature|
      assert_nil ComfortableMexicanSofa::Tag::Template.initialize_tag(
        cms_pages(:default), tag_signature
      )
    end
  end

  def test_content_and_render
    tag = ComfortableMexicanSofa::Tag::Template.initialize_tag(
      cms_pages(:default), '{{cms:template:path/to/template}}'
    )
    assert_equal "<%= render :template => 'path/to/template' %>", tag.content
    assert_equal "<%= render :template => 'path/to/template' %>", tag.render
  end

  def test_whitelisted_paths
    ComfortableMexicanSofa.config.allowed_templates = ['safe/path']

    tag = ComfortableMexicanSofa::Tag::Template.initialize_tag(
      cms_pages(:default), '{{cms:template:safe/path}}'
    )
    assert_equal "<%= render :template => 'safe/path' %>", tag.content
    assert_equal "<%= render :template => 'safe/path' %>", tag.render

    tag = ComfortableMexicanSofa::Tag::Template.initialize_tag(
      cms_pages(:default), '{{cms:template:unsafe/path}}'
    )
    assert_equal "<%= render :template => 'unsafe/path' %>", tag.content
    assert_equal nil, tag.render
  end

end