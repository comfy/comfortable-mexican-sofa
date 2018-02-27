# frozen_string_literal: true

require_relative "../../../../test_helper"

class Comfy::Admin::Cms::SitesControllerTest < ActionDispatch::IntegrationTest

  def test_get_index
    Comfy::Cms::Site.create!(hostname: "other.test")

    r :get, comfy_admin_cms_sites_path
    assert_response :success
    assert assigns(:sites)
    assert_template :index
  end

  def test_get_index_with_no_sites
    Comfy::Cms::Site.delete_all
    r :get, comfy_admin_cms_sites_path
    assert_response :redirect
    assert_redirected_to new_comfy_admin_cms_site_path
  end

  def test_get_new
    r :get, new_comfy_admin_cms_site_path
    assert_response :success
    assert assigns(:site)
    assert_equal "www.example.com", assigns(:site).hostname
    assert_template :new
    assert_select "form[action='/admin/sites']"
  end

  def test_get_edit
    site = comfy_cms_sites(:default)
    r :get, edit_comfy_admin_cms_site_path(id: site)
    assert_response :success
    assert assigns(:site)
    assert_template :edit
    assert_select "form[action='/admin/sites/#{site.id}']"
  end

  def test_get_edit_failure
    r :get, edit_comfy_admin_cms_site_path(id: "invalid")
    assert_response :redirect
    assert_redirected_to action: :index
    assert_equal "Site not found", flash[:danger]
  end

  def test_create
    assert_difference "Comfy::Cms::Site.count" do
      r :post, comfy_admin_cms_sites_path, params: { site: {
        label:      "Test Site",
        identifier: "test-site",
        hostname:   "test.site.local"
      } }
      assert_response :redirect
      site = Comfy::Cms::Site.last
      assert_redirected_to comfy_admin_cms_site_layouts_path(site_id: site)
      assert_equal "Site created", flash[:success]
    end
  end

  def test_creation_failure
    assert_no_difference "Comfy::Cms::Site.count" do
      r :post, comfy_admin_cms_sites_path, params: { site: {} }
      assert_response :success
      assert_template :new
      assert_equal "Failed to create site", flash[:danger]
    end
  end

  def test_update
    site = comfy_cms_sites(:default)
    r :put, comfy_admin_cms_site_path(id: site), params: { site: {
      label:    "New Site",
      hostname: "new.site.local",
      locale:   "es"
    } }
    assert_response :redirect
    assert_redirected_to action: :edit, id: site
    assert_equal "Site updated", flash[:success]
    site.reload
    assert_equal "New Site", site.label
    assert_equal "new.site.local", site.hostname
    assert_equal "es", site.locale
  end

  def test_update_failure
    site = comfy_cms_sites(:default)
    r :put, comfy_admin_cms_site_path(id: site), params: { site: {
      hostname: ""
    } }
    assert_response :success
    assert_template :edit
    site.reload
    assert_not_equal "", site.hostname
    assert_equal "Failed to update site", flash[:danger]
  end

  def test_destroy
    assert_difference "Comfy::Cms::Site.count", -1 do
      r :delete, comfy_admin_cms_site_path(id: comfy_cms_sites(:default))
      assert_response :redirect
      assert_redirected_to action: :index
      assert_equal "Site deleted", flash[:success]
    end
  end

end
