require_relative '../../../test_helper'

class Comfy::Cms::AssetsControllerTest < ActionController::TestCase

  def test_render_css
    get :render_css, :site_id => cms_sites(:default).id, :identifier => cms_layouts(:default).identifier
    assert_response :success
    assert_match 'text/css', response.content_type
    assert_equal cms_layouts(:default).css, response.body
  end

  def test_render_css_not_found
    get :render_css, :site_id => cms_sites(:default).id, :identifier => 'bogus'
    assert_response 404
  end

  def test_render_js
    xhr :get, :render_js, :site_id => cms_sites(:default).id, :identifier => cms_layouts(:default).identifier
    assert_response :success
    assert_equal 'text/javascript', response.content_type
    assert_equal cms_layouts(:default).js, response.body
  end

  def test_render_js_not_found
    xhr :get, :render_js, :site_id => cms_sites(:default).id, :identifier => 'bogus'
    assert_response 404
  end

end