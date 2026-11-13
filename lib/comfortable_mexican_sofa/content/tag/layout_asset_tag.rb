# frozen_string_literal: true

# This tag allows for linking of js and css content defined on the layout.
# Looks something like this:
#   {{cms:layout_asset layout_identifier, type: css, as: tag}}
#
# `type` - css (default) | js - what we're outputting here
# `as`   - url (default) | tag - output url or wrap it in the appropriate tag
#
class ComfortableMexicanSofa::Content::Tag::LayoutAssetTag < ComfortableMexicanSofa::Content::Tag
  attr_reader :identifier, :type, :as

  def initialize(context:, params: [], source: nil)
    super

    @identifier = params[0]
    @type       = options["type"] || "css"
    @as         = options["as"] || "url"

    return if @identifier.present?

    raise Error, "Missing layout identifier for asset tag: #{source}"
  end

  def content
    layout = context.site.layouts.find_by(identifier: @identifier)
    return "" unless layout

    helpers     = ActionController::Base.helpers
    url_helpers = Rails.application.routes.url_helpers

    if @type == "js"
      js_path = url_helpers.comfy_cms_render_js_path(
        site_id:      context.site.id,
        identifier:   layout.identifier,
        cache_buster: layout.cache_buster,
        format:       "js"
      )

      if @as == "tag"
        helpers.javascript_include_tag(js_path)
      else
        js_path
      end

    else
      css_path = url_helpers.comfy_cms_render_css_path(
        site_id:      context.site.id,
        identifier:   layout.identifier,
        cache_buster: layout.cache_buster,
        format:       "css"
      )

      if @as == "tag"
        helpers.stylesheet_link_tag(css_path, media: "screen")
      else
        css_path
      end
    end
  end
end

ComfortableMexicanSofa::Content::Renderer.register_tag(
  :layout_asset, ComfortableMexicanSofa::Content::Tag::LayoutAssetTag
)
