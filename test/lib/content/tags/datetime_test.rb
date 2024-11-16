# frozen_string_literal: true

require_relative '../../../test_helper'

class ContentTagsDatetimeTest < ActiveSupport::TestCase
  setup do
    @page = comfy_cms_pages(:default)
    @frag = comfy_cms_fragments(:datetime)
  end

  def test_init
    tag = ComfortableMediaSurfer::Content::Tags::Datetime.new(context: @page, params: ['test'])
    assert_equal 'test', tag.identifier
  end

  def test_content
    tag = ComfortableMediaSurfer::Content::Tags::Datetime.new(context: @page, params: [@frag.identifier])
    assert_equal @frag,          tag.fragment
    assert_equal @frag.datetime, tag.content
  end

  def test_render
    tag = ComfortableMediaSurfer::Content::Tags::Datetime.new(context: @page, params: [@frag.identifier])
    assert_equal '1981-10-04 12:34:56 UTC', tag.render
  end

  def test_render_with_strftime
    params = [@frag.identifier, { 'strftime' => 'at %I:%M%p' }]
    tag = ComfortableMediaSurfer::Content::Tags::Datetime.new(context: @page, params: params)
    assert_equal 'at 12:34PM', tag.render
  end

  def test_render_not_renderable
    tag = ComfortableMediaSurfer::Content::Tags::Datetime.new(
      context: @page,
      params: [@frag.identifier, { 'render' => 'false' }]
    )
    assert_equal '', tag.render
  end
end
