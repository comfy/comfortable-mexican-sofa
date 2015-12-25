require_relative '../../test_helper'

class CollectionTagTest < ActiveSupport::TestCase

  module TestCollectionScope
    def self.included(base)
      base.scope :cms_collection, lambda{|*args| base.where(:identifier => args.first) if args.first }
    end
  end
  Comfy::Cms::Snippet.send(:include, TestCollectionScope)

  def test_initialize_tag
    assert tag = ComfortableMexicanSofa::Tag::Collection.initialize_tag(
      comfy_cms_pages(:default), '{{ cms:collection:snippet:comfy/cms/snippet }}'
    )
    assert_equal 'snippet',                     tag.identifier
    assert_nil                                  tag.namespace
    assert_equal 'Comfy::Cms::Snippet',         tag.collection_class
    assert_equal 'partials/comfy/cms/snippets', tag.collection_partial
    assert_equal 'label',                       tag.collection_title
    assert_equal 'id',                          tag.collection_identifier
    assert_equal [],                            tag.collection_params

    assert tag = ComfortableMexicanSofa::Tag::Collection.initialize_tag(
      comfy_cms_pages(:default), '{{ cms:collection:namespace.snippet:cms/snippet }}'
    )
    assert_equal 'namespace.snippet', tag.identifier
    assert_equal 'namespace', tag.namespace
  end

  def test_initialize_tag_detailed
    assert tag = ComfortableMexicanSofa::Tag::Collection.initialize_tag(
      comfy_cms_pages(:default),
      '{{ cms:collection:snippet:comfy/cms/snippet:path/to/partial:title:identifier:param_a:param_b }}'
    )
    assert_equal 'snippet',               tag.identifier
    assert_equal 'Comfy::Cms::Snippet',   tag.collection_class
    assert_equal 'path/to/partial',       tag.collection_partial
    assert_equal 'title',                 tag.collection_title
    assert_equal 'identifier',            tag.collection_identifier
    assert_equal ['param_a', 'param_b'],  tag.collection_params
  end

  def test_initialize_tag_failure
    [
      '{{cms:collection}}',
      '{{cms:collection:label}}',
      '{{cms:not_collection:label:class:partial}}',
      '{not_a_tag}'
    ].each do |tag_signature|
      assert_nil ComfortableMexicanSofa::Tag::Collection.initialize_tag(
        comfy_cms_pages(:default), tag_signature
      )
    end
  end

  def test_collection_objects
    assert tag = ComfortableMexicanSofa::Tag::Collection.initialize_tag(
      comfy_cms_pages(:default), '{{ cms:collection:snippet:comfy/cms/snippet }}'
    )
    assert snippets = tag.collection_objects
    assert_equal 1, snippets.count
    assert snippets.first.is_a?(Comfy::Cms::Snippet)
  end

  def test_collection_objects_with_scope
    identifier = comfy_cms_snippets(:default).identifier
    assert tag = ComfortableMexicanSofa::Tag::Collection.initialize_tag(
      comfy_cms_pages(:default),
      "{{ cms:collection:snippet:comfy/cms/snippet:path/to/partial:label:identifier:#{identifier} }}"
    )
    assert snippets = tag.collection_objects
    assert_equal 1, snippets.count
    assert snippets.first.is_a?(Comfy::Cms::Snippet)

    assert tag = ComfortableMexicanSofa::Tag::Collection.initialize_tag(
      comfy_cms_pages(:default), "{{ cms:collection:snippet:comfy/cms/snippet:path/to/partial:label:slug:invalid }}"
    )
    assert snippets = tag.collection_objects
    assert_equal 0, snippets.count
  end

  def test_content_and_render
    assert tag = ComfortableMexicanSofa::Tag::Collection.initialize_tag(
      comfy_cms_pages(:default), '{{ cms:collection:snippet:comfy/cms/snippet }}'
    )
    assert tag.block.content.blank?

    snippet = comfy_cms_snippets(:default)
    tag.block.content = snippet.id.to_s
    assert_equal snippet.id.to_s, tag.block.content
    assert_equal snippet.id.to_s, tag.content
    assert_equal "<%= render :partial => 'partials/comfy/cms/snippets', :locals => {:model => 'Comfy::Cms::Snippet', :identifier => '#{snippet.id}'} %>", tag.render
  end

  def test_content_and_render_detailed
    assert tag = ComfortableMexicanSofa::Tag::Collection.initialize_tag(
      comfy_cms_pages(:default), '{{ cms:collection:snippet:comfy/cms/snippet:path/to/partial:label:slug:param_a:param_b }}'
    )
    assert tag.block.content.blank?

    snippet = comfy_cms_snippets(:default)
    tag.block.content = snippet.identifier
    assert_equal snippet.identifier, tag.block.content
    assert_equal snippet.identifier, tag.content
    assert_equal "<%= render :partial => 'path/to/partial', :locals => {:model => 'Comfy::Cms::Snippet', :identifier => '#{snippet.identifier}', :param_1 => 'param_a', :param_2 => 'param_b'} %>", tag.render
  end

  def test_content_and_render_with_no_content
    assert tag = ComfortableMexicanSofa::Tag::Collection.initialize_tag(
      comfy_cms_pages(:default), '{{ cms:collection:snippet:cms/snippet:path/to/partial }}'
    )
    assert tag.block.content.blank?
    assert_equal '', tag.render
  end

end