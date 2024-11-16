# frozen_string_literal: true

require_relative '../../../test_helper'

class ContentTagsFragmentTest < ActiveSupport::TestCase
  setup do
    @page = comfy_cms_pages(:default)
  end

  def test_init
    tag = ComfortableMediaSurfer::Content::Tags::Fragment.new(context: @page, params: ['content'])
    assert_equal @page,     tag.context
    assert_equal 'content', tag.identifier
    assert_equal true,      tag.renderable
    assert_equal 'default', tag.namespace
  end

  def test_init_with_params
    tag = ComfortableMediaSurfer::Content::Tags::Fragment.new(
      context: @page,
      params: ['content', { 'render' => 'false', 'namespace' => 'test' }]
    )
    assert_equal false,  tag.renderable
    assert_equal 'test', tag.namespace
  end

  def test_init_without_identifier
    message = 'Missing identifier for fragment tag: {{cms:markdown}}'
    assert_raises ComfortableMediaSurfer::Content::Tag::Error, message do
      ComfortableMediaSurfer::Content::Tags::Fragment.new(context: @page, source: '{{cms:markdown}}')
    end
  end

  def test_fragment
    tag = ComfortableMediaSurfer::Content::Tags::Fragment.new(context: @page, params: ['content'])
    assert_equal comfy_cms_fragments(:default), tag.fragment
  end

  def test_fragment_new_record
    tag = ComfortableMediaSurfer::Content::Tags::Fragment.new(context: @page, params: ['new'])
    fragment = tag.fragment
    assert fragment.is_a?(Comfy::Cms::Fragment)
    assert fragment.new_record?
  end

  def test_content
    tag = ComfortableMediaSurfer::Content::Tags::Fragment.new(context: @page, params: ['content'])
    assert_equal 'content', tag.content
    assert_raises RuntimeError, 'Form field rendering not implemented for this Tag' do
      tag.form_field
    end
  end

  def test_content_new_record
    tag = ComfortableMediaSurfer::Content::Tags::Fragment.new(context: @page, params: ['new'])
    assert_nil tag.content
  end

  def test_render
    tag = ComfortableMediaSurfer::Content::Tags::Fragment.new(context: @page, params: ['content'])
    assert_equal 'content', tag.render
  end

  def test_render_when_not_renderable
    tag = ComfortableMediaSurfer::Content::Tags::Fragment.new(
      context: @page,
      params: ['content', { 'render' => 'false' }]
    )
    assert_equal '', tag.render
  end
end
