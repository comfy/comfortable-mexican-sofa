# frozen_string_literal: true

require_relative '../../../test_helper'

class ContentTagsTextAreaTest < ActiveSupport::TestCase
  setup do
    @page = comfy_cms_pages(:default)
  end

  def test_init
    tag = ComfortableMediaSurfer::Content::Tags::Textarea.new(context: @page, params: ['test'])
    assert_equal 'test', tag.identifier
  end
end
