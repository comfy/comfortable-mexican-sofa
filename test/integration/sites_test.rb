require File.expand_path('../test_helper', File.dirname(__FILE__))

class SitesTest < ActionDispatch::IntegrationTest
  
  def test_get_admin
    http_auth :get, cms_admin_pages_path
    assert_response :success
  end
  
  def test_get_admin_with_no_site
    Cms::Site.delete_all
    assert_difference 'Cms::Site.count' do
      http_auth :get, cms_admin_pages_path
      assert_response :redirect
      assert_redirected_to new_cms_admin_page_path
      site = Cms::Site.first
      assert_equal 'test.host', site.hostname
      assert_equal 'Default Site', site.label
    end
  end
  
  def test_get_admin_with_wrong_site
    site = cms_sites(:default)
    site.update_attribute(:hostname, 'remote.host')
    assert_no_difference 'Cms::Site.count' do
      http_auth :get, cms_admin_pages_path
      assert_response :success
      site.reload
      assert_equal 'test.host', site.hostname
    end
  end
  
  def test_get_admin_with_two_wrong_sites
    ComfortableMexicanSofa.config.enable_multiple_sites = true
    Cms::Site.delete_all
    Cms::Site.create!(:label => 'Site1', :hostname => 'site1.host')
    Cms::Site.create!(:label => 'Site2', :hostname => 'site2.host')
    assert_no_difference 'Cms::Site.count' do
      http_auth :get, cms_admin_pages_path
      assert_response :redirect
      assert_redirected_to cms_admin_sites_path
      assert_equal 'No Site defined for this hostname. Create it now.', flash[:error]
    end
  end
  
  def test_get_admin_with_no_site_and_multiple_sites_enabled
    ComfortableMexicanSofa.config.enable_multiple_sites = true
    Cms::Site.delete_all
    assert_no_difference 'Cms::Site.count' do
      http_auth :get, cms_admin_pages_path
      assert_response :redirect
      assert_redirected_to cms_admin_sites_path
      assert_equal 'No Site defined for this hostname. Create it now.', flash[:error]
    end
  end
  
  def test_get_public_page_for_wrong_host_with_single_site
    host! 'bogus.host'
    get '/'
    assert_response :success
    assert assigns(:cms_site)
    assert_equal 'test.host', assigns(:cms_site).hostname
  end
  
  def test_get_public_page_for_wrong_host_with_mutiple_sites
    ComfortableMexicanSofa.config.enable_multiple_sites = true
    host! 'bogus.host'
    get '/'
    assert_response 404
    assert_equal 'Site Not Found', response.body
  end
  
end