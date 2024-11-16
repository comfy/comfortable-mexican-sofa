# frozen_string_literal: true

# This tag allows for linking of js and css content defined on the layout.
# Looks something like this:
#   {{cms:asset layout_identifier, type: css, as: tag}}
#
# `type` - css | js - what we're outputting here
# `as`   - url (default) | tag - output url or wrap it in the appropriate tag
#
class ComfortableMediaSurfer::Content::Tags::Asset < ComfortableMediaSurfer::Content::Tag
  attr_reader :identifier, :type, :as

  def initialize(context:, params: [], source: nil)
    super

    options = params.extract_options!
    @identifier = params[0]
    @type       = options['type']
    @as         = options['as'] || 'url'

    return if @identifier.present?

    raise Error, 'Missing layout identifier for asset tag'
  end

  def layout
    @layout ||= context.site.layouts.find_by(identifier: @identifier)
  end

  def content
    return '' unless layout

    base = ComfortableMediaSurfer.config.public_cms_path || ''
    unless base.ends_with?('/')
      base += '/'
    end

    case @type
    when 'css'
      out = "#{base}cms-css/#{context.site.id}/#{@identifier}/#{layout.cache_buster}.css"
      if @as == 'tag'
        out = "<link href='#{out}' media='screen' rel='stylesheet' type='text/css' />"
      end
      out
    when 'js'
      out = "#{base}cms-js/#{context.site.id}/#{@identifier}/#{layout.cache_buster}.js"
      if @as == 'tag'
        out = "<script src='#{out}' type='text/javascript'></script>"
      end
      out
    end
  end
end

ComfortableMediaSurfer::Content::Renderer.register_tag(
  :asset, ComfortableMediaSurfer::Content::Tags::Asset
)
