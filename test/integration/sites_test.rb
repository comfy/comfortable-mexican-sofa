require_relative '../test_helper'

class SitesIntegrationTest < ActionDispatch::IntegrationTest
  
  def test_get_admin_with_single_site
    http_auth :get, admin_cms_path
    assert assigns(:site)
    assert_equal cms_sites(:default), assigns(:site)
    assert_response :redirect
    assert_redirected_to admin_cms_site_pages_path(assigns(:site))
  end
  
  def test_get_admin_with_no_site
    Cms::Site.delete_all
    http_auth :get, admin_cms_path
    assert_response :redirect
    assert_redirected_to new_admin_cms_site_path
    assert_equal 'Site not found', flash[:error]
  end
  
  def test_get_public_page_with_single_site
    host! 'bogus.host'
    get '/'
    assert_response :success
    assert assigns(:cms_site)
    assert_equal 'test.host', assigns(:cms_site).hostname
  end
  
  def test_get_public_page_with_sites_with_different_paths
    Cms::Site.delete_all
    site_a = Cms::Site.create!(:identifier => 'site-a', :hostname => 'test.host', :path => '')
    site_b = Cms::Site.create!(:identifier => 'site-b', :hostname => 'test.host', :path => 'path-b')
    site_c = Cms::Site.create!(:identifier => 'site-c', :hostname => 'test.host', :path => 'path-c/child')
    
    [site_a, site_b, site_c].each do |site|
      layout  = site.layouts.create!(:identifier => 'test')
      site.pages.create!(:label => 'index', :layout => layout)
      site.pages.create!(:label => '404', :slug => '404', :layout => layout)
    end
    
    %w(/ /path-a /path-a/child /path-c).each do |path|
      get path
      assert assigns(:cms_site), path
      assert_equal site_a, assigns(:cms_site)
      assert_equal path.gsub(/^\//, ''), @controller.params[:cms_path].to_s
    end
    
    %w(/path-b /path-b/child).each do |path|
      get path
      assert assigns(:cms_site), path
      assert_equal site_b, assigns(:cms_site)
      assert_equal path.gsub(/^\/path-b/, '').gsub(/^\//, ''), @controller.params[:cms_path].to_s
    end
    
    %w(/path-c/child /path-c/child/child).each do |path|
      get path
      assert assigns(:cms_site), path
      assert_equal site_c, assigns(:cms_site)
      assert_equal path.gsub(/^\/path-c\/child/, '').gsub(/^\//, ''), @controller.params[:cms_path].to_s
    end
  end
  
  def test_get_public_page_with_host_with_port
    Cms::Site.delete_all
    site_a = Cms::Site.create!(:identifier => 'site-a', :hostname => 'test.host:3000')
    site_b = Cms::Site.create!(:identifier => 'site-b', :hostname => 'test.host')
    
    [site_a, site_b].each do |site|
      layout  = site.layouts.create!(:identifier => 'test')
      site.pages.create!(:label => 'index', :layout => layout)
      site.pages.create!(:label => '404', :slug => '404', :layout => layout)
    end
    
    get '/'
    assert assigns(:cms_site)
    assert_equal site_b, assigns(:cms_site)
  end
  
  def test_get_public_with_locale
    get '/'
    assert_response :success
    assert assigns(:cms_site)
    assert_equal :en, I18n.locale
    
    cms_sites(:default).update_columns(:locale => 'fr')
    get '/'
    assert_response :success
    assert assigns(:cms_site)
    assert_equal :fr, I18n.locale
  end
  
  def test_get_admin_with_locale
    http_auth :get, admin_cms_site_pages_path(cms_sites(:default))
    assert_response :success
    assert_equal :en, I18n.locale
    
    cms_sites(:default).update_columns(:locale => 'fr')
    http_auth :get, admin_cms_site_pages_path(cms_sites(:default))
    assert_response :success
    assert_equal :fr, I18n.locale
  end
  
  def test_get_admin_with_forced_locale
    ComfortableMexicanSofa.config.admin_locale = :en
    
    cms_sites(:default).update_columns(:locale => 'fr')
    http_auth :get, admin_cms_site_pages_path(cms_sites(:default))
    assert_response :success
    assert_equal :en, I18n.locale

    I18n.default_locale = :fr
    I18n.locale = :fr
    http_auth :get, admin_cms_sites_path
    assert_response :success
    assert_equal :en, I18n.locale

    I18n.default_locale = :en
  end
  
end