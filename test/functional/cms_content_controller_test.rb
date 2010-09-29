require File.dirname(__FILE__) + '/../test_helper'

class CmsContentControllerTest < ActionController::TestCase

  def test_something
    flunk
  end
  
  def test_render_css
    get :render_css, :id => cms_layouts(:default)
    assert_response :success
    assert_match %r{text\/css}, @response.headers["Content-Type"]
    assert_equal cms_layouts(:default).css, @response.body
  end
  
  def test_render_js
    get :render_js, :id => cms_layouts(:default)
    assert_response :success
    assert_match %r{text\/javascript}, @response.headers["Content-Type"]
    assert_equal cms_layouts(:default).js, @response.body
  end
  
  def test_render_css_and_js_for_nonexistent_layout
    get :render_css, :id => 'bogus'
    assert_response :success
    get :render_js, :id => 'bogus'
    assert_response :success
  end
  
end
