require_relative '../test_helper'

class AccessControlTest < ActionDispatch::IntegrationTest

  module TestAuthentication
    def authenticate
      render :text => 'Test Login Denied', :status => :unauthorized
    end
  end

  module TestAuthorization
    def authorize
      @authorization_vars = self.instance_variables
      render :text => 'Test Access Denied', :status => :forbidden
    end
  end

  def test_admin_authentication_default
    assert_equal 'ComfortableMexicanSofa::AccessControl::AdminAuthentication',
      ComfortableMexicanSofa.config.admin_auth

    get '/admin/sites'
    assert_response :unauthorized

    http_auth :get, '/admin/sites'
    assert_response :success
  end

  def test_admin_authentication_custom
    skip
    ComfortableMexicanSofa.config.admin_auth = 'AccessControlTest::TestAuthentication'
    reload_access_control_modules

    get '/admin/sites'
    assert_response :unauthorized
    assert_equal 'Test Login Denied', response.body
  end

  def test_admin_authorization_default
    assert_equal 'ComfortableMexicanSofa::AccessControl::AdminAuthorization',
      ComfortableMexicanSofa.config.admin_authorization

    Comfy::Admin::Cms::BaseController.send(:include, ComfortableMexicanSofa::AccessControl::AdminAuthorization)
    http_auth :get, "/admin/sites/#{comfy_cms_sites(:default).to_param}/edit"
    assert_response :success, response.body
  end

  def test_admin_authorization_custom
    skip
    ComfortableMexicanSofa.config.admin_authorization = 'AccessControlTest::TestAuthorization'

    site = comfy_cms_sites(:default)
    http_auth :get, edit_comfy_admin_cms_site_path(site)
    assert_response :forbidden
    assert_equal 'Test Access Denied', response.body
    assert assigns(:authorization_vars)
    assert assigns(:authorization_vars).member?(:@site)

    layout = comfy_cms_layouts(:default)
    http_auth :get, edit_comfy_admin_cms_site_layout_path(site, layout)
    assert assigns(:authorization_vars).member?(:@site)
    assert assigns(:authorization_vars).member?(:@layout)

    revision = comfy_cms_revisions(:layout)
    http_auth :get, comfy_admin_cms_site_layout_revision_path(site, layout, revision)
    assert assigns(:authorization_vars).member?(:@site)
    assert assigns(:authorization_vars).member?(:@record)

    page = comfy_cms_pages(:default)
    http_auth :get, edit_comfy_admin_cms_site_page_path(site, page)
    assert assigns(:authorization_vars).member?(:@site)
    assert assigns(:authorization_vars).member?(:@page)

    snippet = comfy_cms_snippets(:default)
    http_auth :get, edit_comfy_admin_cms_site_snippet_path(site, snippet)
    assert assigns(:authorization_vars).member?(:@site)
    assert assigns(:authorization_vars).member?(:@snippet)

    file = comfy_cms_files(:default)
    http_auth :get, edit_comfy_admin_cms_site_file_path(site, file)
    assert assigns(:authorization_vars).member?(:@site)
    assert assigns(:authorization_vars).member?(:@file)

    category = comfy_cms_categories(:default)
    http_auth :get, edit_comfy_admin_cms_site_category_path(site, category)
    assert assigns(:authorization_vars).member?(:@site)
    assert assigns(:authorization_vars).member?(:@category)
  end

  def test_public_authentication_default
    assert_equal 'ComfortableMexicanSofa::AccessControl::PublicAuthentication',
      ComfortableMexicanSofa.config.public_auth

    get '/'
    assert_response :success, response.body
  end

  def test_public_authentication_custom
    skip
    ComfortableMexicanSofa.config.public_auth = 'AccessControlTest::TestAuthentication'

    get '/'
    assert_response :unauthorized
    assert_equal 'Test Login Denied', response.body
  end
end