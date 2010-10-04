require File.dirname(__FILE__) + '/../test_helper'

class CmsContentControllerTest < ActionController::TestCase

  def test_render_page
    get :render_html, :cms_path => ''
    assert_equal assigns(:cms_page), cms_pages(:default)
    assert_response :success
  end
  
  def test_render_page_not_found
    flunk 'TODO'
  end
  
  def test_render_css
    get :render_css, :id => cms_layouts(:default)
    assert_response :success
    assert_match %r{text\/css}, @response.headers["Content-Type"]
    assert_equal cms_layouts(:default).css, @response.body
  end
  
  def test_render_css_not_found
    get :render_css, :id => 'bogus'
    assert_response 404
  end
  
  def test_render_js
    get :render_js, :id => cms_layouts(:default)
    assert_response :success
    assert_match %r{text\/javascript}, @response.headers["Content-Type"]
    assert_equal cms_layouts(:default).js, @response.body
  end
  
  def test_render_js_not_found
    get :render_js, :id => 'bogus'
    assert_response 404
  end
  
end
