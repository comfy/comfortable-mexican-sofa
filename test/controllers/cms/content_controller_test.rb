require_relative '../../test_helper'

class Cms::ContentControllerTest < ActionController::TestCase

  def test_render_page
    get :render_html, :cms_path => ''
    assert_equal cms_sites(:default), assigns(:cms_site)
    assert_equal cms_layouts(:default), assigns(:cms_layout)
    assert_equal cms_pages(:default), assigns(:cms_page)
    
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
    assert_equal 'text/html', response.content_type
  end
  
  def test_render_page_with_app_layout
    cms_layouts(:default).update_columns(:app_layout => 'admin/cms')
    get :render_html, :cms_path => ''
    assert_response :success
    assert assigns(:cms_page)
    assert_select "body[class='c-cms-content a-render-html']"
  end
  
  def test_render_page_with_xhr
    cms_layouts(:default).update_columns(:app_layout => 'cms_admin')
    xhr :get, :render_html, :cms_path => ''
    assert_response :success
    assert assigns(:cms_page)
    assert_no_select "body[class='c_cms_content a_render_html']"
  end
  
  def test_render_page_not_found
    assert_exception_raised ActionController::RoutingError, 'Page Not Found at: "doesnotexist"' do
      get :render_html, :cms_path => 'doesnotexist'
    end
  end
  
  def test_render_page_not_found_with_custom_404
    page = cms_sites(:default).pages.create!(
      :label          => '404',
      :slug           => '404',
      :parent_id      => cms_pages(:default).id,
      :layout_id      => cms_layouts(:default).id,
      :is_published   => '1',
      :blocks_attributes => [
        { :identifier => 'default_page_text',
          :content    => 'custom 404 page content' }
      ]
    )
    assert_equal '/404', page.full_path
    assert page.is_published?
    get :render_html, :cms_path => 'doesnotexist'
    assert_response 404
    assert assigns(:cms_page)
    assert_match /custom 404 page content/, response.body
  end
  
  def test_render_page_with_no_site
    Cms::Site.destroy_all
    
    assert_exception_raised ActionController::RoutingError, 'Site Not Found' do
      get :render_html, :cms_path => ''
    end
  end
  
  def test_render_page_with_no_layout
    Cms::Layout.destroy_all
    
    get :render_html, :cms_path => ''
    assert_response 404
    assert_equal 'Layout Not Found', response.body
  end
  
  def test_render_page_with_redirect
    cms_pages(:child).update_columns(:target_page_id => cms_pages(:default).id)
    assert_equal cms_pages(:default), cms_pages(:child).target_page
    get :render_html, :cms_path => 'child-page'
    assert_response :redirect
    assert_redirected_to cms_pages(:default).url
  end
  
  def test_render_page_unpublished
    page = cms_pages(:default)
    page.update_columns(:is_published => false)
    
    assert_exception_raised ActionController::RoutingError, 'Page Not Found at: ""' do
      get :render_html, :cms_path => ''
    end
  end
  
  def test_render_page_with_irb_disabled
    assert_equal false, ComfortableMexicanSofa.config.allow_irb
    
    irb_page = cms_sites(:default).pages.create!(
      :label          => 'irb',
      :slug           => 'irb',
      :parent_id      => cms_pages(:default).id,
      :layout_id      => cms_layouts(:default).id,
      :is_published   => '1',
      :blocks_attributes => [
        { :identifier => 'default_page_text',
          :content    => 'text <%= 2 + 2 %> text' }
      ]
    )
    get :render_html, :cms_path => 'irb'
    assert_response :success
    assert_match "text &lt;%= 2 + 2 %&gt; text", response.body
  end
  
  def test_render_page_with_irb_enabled
    ComfortableMexicanSofa.config.allow_irb = true
    
    irb_page = cms_sites(:default).pages.create!(
      :label          => 'irb',
      :slug           => 'irb',
      :parent_id      => cms_pages(:default).id,
      :layout_id  => cms_layouts(:default).id,
      :is_published   => '1',
      :blocks_attributes => [
        { :identifier => 'default_page_text',
          :content    => 'text <%= 2 + 2 %> text' }
      ]
    )
    get :render_html, :cms_path => 'irb'
    assert_response :success
    assert_match "text 4 text", response.body
  end
  
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
    get :render_js, :site_id => cms_sites(:default).id, :identifier => cms_layouts(:default).identifier
    assert_response :success
    assert_equal 'text/javascript', response.content_type
    assert_equal cms_layouts(:default).js, response.body
  end
  
  def test_render_js_not_found
    get :render_js, :site_id => cms_sites(:default).id, :identifier => 'bogus'
    assert_response 404
  end

  def test_render_sitemap
    get :render_sitemap, :format => :xml
    assert_response :success
    assert_match '<loc>//test.host/child-page</loc>', response.body
  end

  def test_render_sitemap_with_path
    site = cms_sites(:default)
    site.update_columns(:path => 'en')
    
    get :render_sitemap, :cms_path => site.path, :format => :xml
    assert_response :success
    assert_equal cms_sites(:default), assigns(:cms_site)
    assert_match '<loc>//test.host/en/child-page</loc>', response.body
  end
  
  def test_render_sitemap_with_path_invalid_with_single_site
    site = cms_sites(:default)
    site.update_columns(:path => 'en')
    
    assert_exception_raised ActionController::RoutingError, 'Site Not Found' do
      get :render_sitemap, :cms_path => 'fr', :format => :xml
    end
  end

end
