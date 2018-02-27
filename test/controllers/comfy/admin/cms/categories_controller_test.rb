# frozen_string_literal: true

require_relative "../../../../test_helper"

class Comfy::Admin::Cms::CategoriesControllerTest < ActionDispatch::IntegrationTest

  def setup
    @site = comfy_cms_sites(:default)
  end

  def test_get_edit
    r :get, edit_comfy_admin_cms_site_category_path(site_id: @site, id: comfy_cms_categories(:default)), xhr: true
    assert_response :success
    assert_template :edit
    assert assigns(:category)
  end

  def test_get_edit_failure
    r :get, edit_comfy_admin_cms_site_category_path(site_id: @site, id: "invalid"), xhr: true
    assert_response :success
    assert response.body.blank?
  end

  def test_creation
    assert_difference "Comfy::Cms::Category.count" do
      r :post, comfy_admin_cms_site_categories_path(site_id: @site), xhr: true, params: { category: {
        label:            "Test Label",
        categorized_type: "Comfy::Cms::Snippet"
      } }
      assert_response :success
      assert_template :create
      assert assigns(:category)
    end
  end

  def test_creation_failure
    assert_no_difference "Comfy::Cms::Category.count" do
      r :post, comfy_admin_cms_site_categories_path(site_id: @site), xhr: true, params: { category: {} }
      assert_response :success
      assert response.body.blank?
    end
  end

  def test_update
    category = comfy_cms_categories(:default)
    r :put, comfy_admin_cms_site_category_path(site_id: @site, id: category), xhr: true, params: { category: {
      label: "Updated Label"
    } }
    assert_response :success
    assert_template :update
    assert assigns(:category)
    category.reload
    assert_equal "Updated Label", category.label
  end

  def test_update_failure
    category = comfy_cms_categories(:default)
    r :put, comfy_admin_cms_site_category_path(site_id: @site, id: category), xhr: true, params: { category: {
      label: ""
    } }
    assert_response :success
    assert response.body.blank?
    category.reload
    assert_not_equal "", category.label
  end

  def test_destroy
    assert_difference "Comfy::Cms::Category.count", -1 do
      r :delete, comfy_admin_cms_site_category_path(site_id: @site, id: comfy_cms_categories(:default)), xhr: true
      assert assigns(:category)
      assert_response :success
      assert_template :destroy
    end
  end

end
