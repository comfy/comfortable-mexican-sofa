# frozen_string_literal: true

require_relative "../../../test_helper"

class Comfy::Cms::AssetsControllerTest < ActionDispatch::IntegrationTest

  def setup
    @site   = comfy_cms_sites(:default)
    @layout = comfy_cms_layouts(:default)
  end

  def test_render_css_with_site_with_path
    @site.update_column(:path, "some/path")

    get comfy_cms_render_css_path(site_id: @site, identifier: @layout.identifier)
    assert_response :success
    assert_match "text/css", response.content_type
    assert_equal @layout.css, response.body
  end

  def test_render_css_without_cache_buster
    get comfy_cms_render_css_path(site_id: @site, identifier: @layout.identifier)
    assert_response :success
    assert_match "text/css", response.content_type
    assert_equal "max-age=0, private, must-revalidate", response.headers["Cache-Control"]
    assert_equal @layout.css, response.body
  end

  def test_render_css_with_cache_buster
    get comfy_cms_render_css_path(site_id: @site, identifier: @layout.identifier, cache_buster: @layout.cache_buster)
    assert_response :success
    assert_match "text/css", response.content_type
    assert_equal "max-age=31556952, public", response.headers["Cache-Control"]
    assert_equal @layout.css, response.body
  end

  def test_render_css_not_found
    get comfy_cms_render_css_path(site_id: @site, identifier: "invalid")
    assert_response 404
  end

  def test_render_js_without_cache_buster
    get comfy_cms_render_js_path(site_id: @site, identifier: @layout.identifier)
    assert_response :success
    assert_equal "application/javascript", response.content_type
    assert_equal "max-age=0, private, must-revalidate", response.headers["Cache-Control"]
    assert_equal @layout.js, response.body
  end

  def test_render_js_with_cache_buster
    get comfy_cms_render_js_path(site_id: @site, identifier: @layout.identifier, cache_buster: @layout.cache_buster)
    assert_response :success
    assert_equal "application/javascript", response.content_type
    assert_equal "max-age=31556952, public", response.headers["Cache-Control"]
    assert_equal @layout.js, response.body
  end

  def test_render_js_not_found
    get comfy_cms_render_js_path(site_id: @site, identifier: "bogus")
    assert_response 404
  end

end
