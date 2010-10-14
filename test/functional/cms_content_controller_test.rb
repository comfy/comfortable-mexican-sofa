require File.dirname(__FILE__) + '/../test_helper'

class CmsContentControllerTest < ActionController::TestCase

  def test_render_page
    get :render_html, :cms_path => ''
    assert_equal assigns(:cms_page), cms_pages(:default)
    assert_response :success
    assert_equal rendered_content_formatter(
      '
      layout_content_a
      default_page_text_content_a
      default_snippet_content
      default_page_text_content_b
      layout_content_b
      default_snippet_content
      layout_content_c'
    ), @response.body
  end
  
  def test_render_page_with_app_layout
    cms_layouts(:default).update_attribute(:app_layout, 'cms_admin.html.erb')
    get :render_html, :cms_path => ''
    assert_response :success
    assert_select 'body[id=cms_admin]'
  end
  
  def test_render_page_not_found
    get :render_html, :cms_path => 'doesnotexist'
    assert_response 404
  end
  
  def test_render_page_not_found_with_custom_404
    CmsPage.create!(
      :label          => '404',
      :slug           => '404',
      :parent_id      => cms_pages(:default).id,
      :cms_layout_id  => cms_layouts(:default).id,
      :cms_blocks_attributes => [
        { :label    => 'default_page_text',
          :type     => 'CmsTag::PageText',
          :content  => 'custom 404 page content' }
      ]
    )
    get :render_html, :cms_path => 'doesnotexist'
    assert_response 404
    assert assigns(:cms_page)
    assert_match /custom 404 page content/, @response.body
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
