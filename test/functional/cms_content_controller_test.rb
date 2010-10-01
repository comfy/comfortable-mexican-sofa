require File.dirname(__FILE__) + '/../test_helper'

class CmsContentControllerTest < ActionController::TestCase

  def test_render_page
    get :render_page, :cms_path => ''
    assert_equal assigns(:cms_page), cms_pages(:default)
    assert_response :success
  end
  
  def test_render_css
    get :render_css, :cms_path => ''
    assert_response :success
    assert_match %r{text\/css}, @response.headers["Content-Type"]
    assert_equal cms_layouts(:default).css, @response.body
  end
  
  def test_render_nested_css
    get :render_css, :cms_path => 'with-nested_layout'
    assert_response :success
    assert_match %r{text\/css}, @response.headers["Content-Type"]
    assert_equal assigns(:cms_page).cms_layout.merged_css, @response.body
  end
  
  def test_render_js
    get :render_js, :cms_path => ''
    assert_response :success
    assert_match %r{text\/javascript}, @response.headers["Content-Type"]
    assert_equal cms_layouts(:default).js, @response.body
  end
  
  def test_render_nested_js
    get :render_js, :cms_path => 'with-nested_layout'
    assert_response :success
    assert_match %r{text\/javascript}, @response.headers["Content-Type"]
    assert_equal assigns(:cms_page).cms_layout.merged_js, @response.body
  end
  
  def test_render_css_and_js_for_nonexistent_layout
    get :render_css, :cms_path => 'bogus'
    assert_response 404
    get :render_js, :cms_path => 'bogus'
    assert_response 404
  end
  
end
