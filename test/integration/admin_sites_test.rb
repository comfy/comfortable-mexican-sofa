require File.dirname(__FILE__) + '/../test_helper'

class AdminSitesTest < ActionDispatch::IntegrationTest
  
  def test_get_pages_index
    http_auth :get, cms_admin_pages_path
    assert_response :success
  end
  
  def test_get_pages_index_with_no_site
    CmsSite.delete_all
    http_auth :get, cms_admin_pages_path
    assert_response :redirect
    assert_redirected_to new_cms_admin_site_path
  end
  
  def test_get_sites_index_with_no_site
    CmsSite.delete_all
    http_auth :get, cms_admin_sites_path
    assert_response :success
  end
    
end