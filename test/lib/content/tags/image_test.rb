# frozen_string_literal: true

require_relative '../../../test_helper'

class ContentTagsImageTest < ActiveSupport::TestCase
  delegate :rails_blob_path, to: 'Rails.application.routes.url_helpers'

  setup do
    @page = comfy_cms_pages(:default)
    @file = comfy_cms_files(:default)
  end

  # -- Tests -------------------------------------------------------------------

  def test_init
    tag = ComfortableMediaSurfer::Content::Tags::Image.new(context: @page, params: ['my_image'])
    assert_equal 'my_image', tag.identifier
    assert_equal 'image', tag.as
  end

  def test_init_without_identifier
    message = 'Missing identifier label for image tag'
    assert_raises ComfortableMediaSurfer::Content::Tag::Error, message do
      ComfortableMediaSurfer::Content::Tags::Image.new(context: @page)
    end
  end

  def test_file
    tag = ComfortableMediaSurfer::Content::Tags::Image.new(context: @page, params: [@file.label])
    assert_instance_of Comfy::Cms::File, tag.file_record

    tag = ComfortableMediaSurfer::Content::Tags::Image.new(context: @page, params: ['invalid'])
    assert_nil tag.file_record
  end

  def test_content
    tag = ComfortableMediaSurfer::Content::Tags::Image.new(
      context: @page,
      params: [@file.label, { 'as' => 'image', 'class' => 'html-class' }]
    )
    url = rails_blob_path(tag.file, only_path: true)
    out = "<img src='#{url}' class='html-class' alt='default file' title='default file'/>"
    assert_equal out, tag.content
    assert_equal out, tag.render
  end

  def test_content_when_not_found
    tag = ComfortableMediaSurfer::Content::Tags::Image.new(context: @page, params: ['invalid'])
    assert_equal '', tag.content
    assert_equal '', tag.render
  end
end
