require File.expand_path('../test_helper', File.dirname(__FILE__))

class SitesTest < ActionDispatch::IntegrationTest
  
  def test_get_admin_with_single_site
    http_auth :get, cms_admin_path
    assert assigns(:site)
    assert_equal cms_sites(:default), assigns(:site)
    assert_response :redirect
    assert_redirected_to cms_admin_site_pages_path(assigns(:site))
  end
  
  def test_get_admin_with_no_site
    Cms::Site.delete_all
    http_auth :get, cms_admin_path
    assert_response :redirect
    assert_redirected_to new_cms_admin_site_path
    assert_equal 'Site not found', flash[:error]
  end
  
  def test_get_public_page_with_single_site
    host! 'bogus.host'
    get '/'
    assert_response :success
    assert assigns(:cms_site)
    assert_equal 'test.host', assigns(:cms_site).hostname
  end
  
end