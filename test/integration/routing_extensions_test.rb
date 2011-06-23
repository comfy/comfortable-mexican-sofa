require File.expand_path('../test_helper', File.dirname(__FILE__))

class RoutingExtensionsTest < ActionDispatch::IntegrationTest
  
  def teardown
    reset_config
    load(File.expand_path('config/routes.rb', Rails.root))
  end
  
  def test_get_admin_with_admin_route_prefix
    ComfortableMexicanSofa.config.admin_route_prefix = 'custom-admin'
    load(File.expand_path('config/routes.rb', Rails.root))
    
    assert_equal '/custom-admin/sites', cms_admin_sites_path
    http_auth :get, cms_admin_sites_path
    assert_response :success
  end
  
  def test_get_admin_with_admin_route_redirect
    ComfortableMexicanSofa.config.admin_route_redirect = '/cms-admin/sites'
    load(File.expand_path('config/routes.rb', Rails.root))
    
    http_auth :get, '/cms-admin'
    assert_response :redirect
    assert_redirected_to cms_admin_sites_path
  end
  
  def test_get_admin_with_admin_route_prefix_disabled
    ComfortableMexicanSofa.config.admin_route_prefix = ''
    load(File.expand_path('config/routes.rb', Rails.root))
    
    http_auth :get, '/cms-admin'
    assert_response 404
  end
  
end