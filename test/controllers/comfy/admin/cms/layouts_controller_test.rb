# frozen_string_literal: true

require_relative "../../../../test_helper"

class Comfy::Admin::Cms::LayoutsControllerTest < ActionDispatch::IntegrationTest

  setup do
    @site = comfy_cms_sites(:default)
  end

  def test_get_index
    @site.layouts.create!(identifier: "other")

    r :get, comfy_admin_cms_site_layouts_path(site_id: @site)
    assert_response :success
    assert assigns(:layouts)
    assert_template :index
  end

  def test_get_index_with_no_layouts
    Comfy::Cms::Layout.delete_all
    r :get, comfy_admin_cms_site_layouts_path(site_id: @site)
    assert_response :redirect
    assert_redirected_to action: :new
  end

  def test_get_new
    r :get, new_comfy_admin_cms_site_layout_path(site_id: @site)
    assert_response :success
    assert assigns(:layout)
    assert_equal "{{ cms:wysiwyg content }}", assigns(:layout).content
    assert_template :new
    assert_select "form[action='/admin/sites/#{@site.id}/layouts']"
  end

  def test_get_new_with_parent
    layout = comfy_cms_layouts(:default)
    layout.update_column(:app_layout, "application")
    r :get, new_comfy_admin_cms_site_layout_path(site_id: @site), params: { parent_id: layout.id }
    assert_response :success
    assert_equal layout.app_layout, assigns(:layout).app_layout
  end

  def test_get_edit
    layout = comfy_cms_layouts(:default)
    r :get, edit_comfy_admin_cms_site_layout_path(site_id: @site, id: layout)
    assert_response :success
    assert assigns(:layout)
    assert_template :edit
    assert_select "form[action='/admin/sites/#{layout.site.id}/layouts/#{layout.id}']"
  end

  def test_get_edit_failure
    r :get, edit_comfy_admin_cms_site_layout_path(site_id: @site, id: "invalid")
    assert_response :redirect
    assert_redirected_to action: :index
    assert_equal "Layout not found", flash[:danger]
  end

  def test_creation
    assert_difference "Comfy::Cms::Layout.count" do
      r :post, comfy_admin_cms_site_layouts_path(site_id: @site), params: { layout: {
        label:      "Test Layout",
        identifier: "test",
        content:    "Test {{cms:page:content}}"
      } }
      assert_response :redirect
      layout = Comfy::Cms::Layout.last
      assert_equal @site, layout.site
      assert_redirected_to action: :edit, site_id: layout.site, id: layout
      assert_equal "Layout created", flash[:success]
    end
  end

  def test_creation_failure
    assert_no_difference "Comfy::Cms::Layout.count" do
      r :post, comfy_admin_cms_site_layouts_path(site_id: @site), params: { layout: {} }
      assert_response :success
      assert_template :new
      assert_equal "Failed to create layout", flash[:danger]
    end
  end

  def test_update
    layout = comfy_cms_layouts(:default)
    r :put, comfy_admin_cms_site_layout_path(site_id: @site, id: layout), params: { layout: {
      label:    "New Label",
      content:  "New {{cms:page:content}}"
    } }
    assert_response :redirect
    assert_redirected_to action: :edit, site_id: layout.site, id: layout
    assert_equal "Layout updated", flash[:success]
    layout.reload
    assert_equal "New Label", layout.label
    assert_equal "New {{cms:page:content}}", layout.content
  end

  def test_update_failure
    layout = comfy_cms_layouts(:default)
    r :put, comfy_admin_cms_site_layout_path(site_id: @site, id: layout), params: { layout: {
      identifier: ""
    } }
    assert_response :success
    assert_template :edit
    layout.reload
    assert_not_equal "", layout.identifier
    assert_equal "Failed to update layout", flash[:danger]
  end

  def test_destroy
    assert_difference "Comfy::Cms::Layout.count", -1 do
      r :delete, comfy_admin_cms_site_layout_path(site_id: @site, id: comfy_cms_layouts(:default))
      assert_response :redirect
      assert_redirected_to action: :index
      assert_equal "Layout deleted", flash[:success]
    end
  end

  def test_reorder
    layout_one = comfy_cms_layouts(:default)
    layout_two = @site.layouts.create!(
      label:      "test",
      identifier: "test"
    )
    assert_equal 0, layout_one.position
    assert_equal 1, layout_two.position

    r :put, reorder_comfy_admin_cms_site_layouts_path(site_id: @site), params: {
      order: [layout_two.id, layout_one.id]
    }
    assert_response :success
    layout_one.reload
    layout_two.reload

    assert_equal 1, layout_one.position
    assert_equal 0, layout_two.position
  end

end
