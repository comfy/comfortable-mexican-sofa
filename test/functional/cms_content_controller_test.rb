require File.expand_path('../test_helper', File.dirname(__FILE__))

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
    ), response.body
  end
  
  def test_render_page_with_app_layout
    cms_layouts(:default).update_attribute(:app_layout, 'cms_admin.html.erb')
    get :render_html, :cms_path => ''
    assert_response :success
    assert_select "body[class='c_cms_content a_render_html']"
  end
  
  def test_render_page_not_found
    get :render_html, :cms_path => 'doesnotexist'
    assert_response 404
    assert_equal 'Page Not Found', response.body
  end
  
  def test_render_page_not_found_with_custom_404
    page = cms_sites(:default).cms_pages.create!(
      :label          => '404',
      :slug           => '404',
      :parent_id      => cms_pages(:default).id,
      :cms_layout_id  => cms_layouts(:default).id,
      :is_published   => '1',
      :cms_blocks_attributes => [
        { :label    => 'default_page_text',
          :type     => 'CmsTag::PageText',
          :content  => 'custom 404 page content' }
      ]
    )
    assert_equal '/404', page.full_path
    assert page.is_published?
    get :render_html, :cms_path => 'doesnotexist'
    assert_response 404
    assert assigns(:cms_page)
    assert_match /custom 404 page content/, response.body
  end
  
  def test_render_page_with_redirect
    cms_pages(:child).update_attribute(:target_page, cms_pages(:default))
    assert_equal cms_pages(:default), cms_pages(:child).target_page
    get :render_html, :cms_path => 'child-page'
    assert_response :redirect
    assert_redirected_to '/'
  end
  
  def test_render_page_unpublished
    page = cms_pages(:default)
    page.update_attribute(:is_published, false)
    get :render_html, :cms_path => ''
    assert_response 404
  end
  
  def test_render_page_with_irb_disabled
    assert ComfortableMexicanSofa.config.disable_irb
    
    irb_page = cms_sites(:default).cms_pages.create!(
      :label          => 'irb',
      :slug           => 'irb',
      :parent_id      => cms_pages(:default).id,
      :cms_layout_id  => cms_layouts(:default).id,
      :is_published   => '1',
      :cms_blocks_attributes => [
        { :label    => 'default_page_text',
          :type     => 'CmsTag::PageText',
          :content  => 'text <%= 2 + 2 %> text' }
      ]
    )
    get :render_html, :cms_path => 'irb'
    assert_response :success
    assert_match "text &lt;%= 2 + 2 %&gt; text", response.body
  end
  
  def test_render_page_with_irb_enabled
    ComfortableMexicanSofa.config.disable_irb = false
    
    irb_page = cms_sites(:default).cms_pages.create!(
      :label          => 'irb',
      :slug           => 'irb',
      :parent_id      => cms_pages(:default).id,
      :cms_layout_id  => cms_layouts(:default).id,
      :is_published   => '1',
      :cms_blocks_attributes => [
        { :label    => 'default_page_text',
          :type     => 'CmsTag::PageText',
          :content  => 'text <%= 2 + 2 %> text' }
      ]
    )
    get :render_html, :cms_path => 'irb'
    assert_response :success
    assert_match "text 4 text", response.body
  end
  
  def test_render_css
    get :render_css, :id => cms_layouts(:default).slug
    assert_response :success
    assert_match %r{text\/css}, response.headers["Content-Type"]
    assert_equal cms_layouts(:default).css, response.body
  end
  
  def test_render_css_not_found
    get :render_css, :id => 'bogus'
    assert_response 404
  end
  
  def test_render_js
    get :render_js, :id => cms_layouts(:default).slug
    assert_response :success
    assert_match %r{text\/javascript}, response.headers["Content-Type"]
    assert_equal cms_layouts(:default).js, response.body
  end
  
  def test_render_js_not_found
    get :render_js, :id => 'bogus'
    assert_response 404
  end
  
end
