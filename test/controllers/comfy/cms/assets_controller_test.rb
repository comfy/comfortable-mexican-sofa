require_relative '../../../test_helper'

class Comfy::Cms::AssetsControllerTest < ActionController::TestCase

  def test_render_css_with_site_with_path
    site = comfy_cms_sites(:default)
    site.update_column(:path, 'some/path')
    get :render_css, :site_id => site, :identifier => comfy_cms_layouts(:default).identifier
    assert_response :success
    assert_match 'text/css', response.content_type
    assert_equal comfy_cms_layouts(:default).css, response.body
  end

  def test_render_css_without_cache_buster
    get :render_css, :site_id => comfy_cms_sites(:default), :identifier => comfy_cms_layouts(:default).identifier
    assert_response :success
    assert_match 'text/css', response.content_type
    assert_nil response.headers['Cache-Control']
    assert_equal comfy_cms_layouts(:default).css, response.body
  end

  def test_render_css_with_cache_buster
    layout = comfy_cms_layouts(:default)
    get :render_css, :site_id => comfy_cms_sites(:default), :identifier => layout.identifier, :cache_buster => layout.cache_buster
    assert_response :success
    assert_match 'text/css', response.content_type
    assert_equal 'public, max-age=31557600', response.headers['Cache-Control']
    assert_equal comfy_cms_layouts(:default).css, response.body
  end

  def test_render_css_not_found
    get :render_css, :site_id => comfy_cms_sites(:default).id, :identifier => 'bogus'
    assert_response 404
  end

  def test_render_js_without_cache_buster
    xhr :get, :render_js, :site_id => comfy_cms_sites(:default).id, :identifier => comfy_cms_layouts(:default).identifier
    assert_response :success
    assert_equal 'application/javascript', response.content_type
    assert_nil response.headers['Cache-Control']
    assert_equal comfy_cms_layouts(:default).js, response.body
  end

  def test_render_js_with_cache_buster
    layout = comfy_cms_layouts(:default)
    xhr :get, :render_js, :site_id => comfy_cms_sites(:default).id, :identifier => layout.identifier, :cache_buster => layout.cache_buster
    assert_response :success
    assert_equal 'application/javascript', response.content_type
    assert_equal 'public, max-age=31557600', response.headers['Cache-Control']
    assert_equal comfy_cms_layouts(:default).js, response.body
  end

  def test_render_js_not_found
    xhr :get, :render_js, :site_id => comfy_cms_sites(:default).id, :identifier => 'bogus'
    assert_response 404
  end

end
