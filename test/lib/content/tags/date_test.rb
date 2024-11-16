# frozen_string_literal: true

require_relative '../../../test_helper'

class ContentTagsDateTest < ActiveSupport::TestCase
  setup do
    @page = comfy_cms_pages(:default)
  end

  def test_init
    tag = ComfortableMediaSurfer::Content::Tags::Date.new(context: @page, params: ['test'])
    assert_equal 'test', tag.identifier
  end

  def test_content
    frag = comfy_cms_fragments(:datetime)
    tag = ComfortableMediaSurfer::Content::Tags::Date.new(context: @page, params: [frag.identifier])
    assert_equal frag,          tag.fragment
    assert_equal frag.datetime, tag.content
  end
end
