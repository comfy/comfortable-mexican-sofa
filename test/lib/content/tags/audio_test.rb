# frozen_string_literal: true

require_relative '../../../test_helper'

class ContentTagsAudioTest < ActiveSupport::TestCase
  def test_init
    tag = ComfortableMediaSurfer::Content::Tags::Audio.new(
      context: @page,
      params: ['path/to/audio']
    )
    assert_equal 'path/to/audio', tag.path
    assert_equal ({}), tag.locals
  end

  def test_init_with_locals
    tag = ComfortableMediaSurfer::Content::Tags::Audio.new(
      context: @page,
      params: ['path/to/audio', { 'key' => 'val' }]
    )
    assert_equal 'path/to/audio', tag.path
    assert_equal ({ 'key' => 'val' }), tag.locals
  end

  def test_init_without_path
    message = 'Missing path for audio tag'
    assert_raises ComfortableMediaSurfer::Content::Tag::Error, message do
      ComfortableMediaSurfer::Content::Tags::Audio.new(
        context: @page,
        params: [{ 'key' => 'val' }]
      )
    end
  end

  def test_render
    tag = ComfortableMediaSurfer::Content::Tags::Audio.new(
      context: @page,
      params: ['path/to/audio', { 'style' => 'font-weight: bold' }]
    )
    html = '<style>.audioplayer {font-weight: bold}</style><audio controls class="audioplayer" src=path/to/audio></audio>'
    assert_equal html, tag.render
  end
end
