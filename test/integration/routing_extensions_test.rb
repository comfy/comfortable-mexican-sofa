require File.expand_path('../test_helper', File.dirname(__FILE__))

class RoutingExtensionsTest < ActionDispatch::IntegrationTest
  
  def teardown
    reset_config
    load(File.expand_path('config/routes.rb', Rails.root))
  end
  
  def test_get_public_with_content_route_prefix
    ComfortableMexicanSofa.config.content_route_prefix = 'custom'
    load(File.expand_path('config/routes.rb', Rails.root))
    
    get '/custom'
    assert_response :success
    assert assigns(:cms_page)
    assert_equal '/', assigns(:cms_page).full_path
    
    get '/custom/child-page'
    assert_response :success
    assert assigns(:cms_page)
    assert_equal '/child-page', assigns(:cms_page).full_path
  end
  
  def test_get_admin_with_admin_route_prefix
    ComfortableMexicanSofa.config.admin_route_prefix = 'custom-admin'
    load(File.expand_path('config/routes.rb', Rails.root))
    
    assert_equal '/custom-admin/pages', cms_admin_pages_path
    http_auth :get, cms_admin_pages_path
    assert_response :success
  end
  
end