# frozen_string_literal: true

require_relative "../../../../../test_helper"

class Comfy::Admin::Cms::Revisions::TranslationControllerTest < ActionDispatch::IntegrationTest

  setup do
    @site         = comfy_cms_sites(:default)
    @page         = comfy_cms_pages(:default)
    @translation  = comfy_cms_translations(:default)
    @revision     = comfy_cms_revisions(:translation)
  end

  def test_get_index
    r :get, comfy_admin_cms_site_page_translation_revisions_path(@site, @page, @translation)
    assert_response :redirect
    assert_redirected_to action: :show, id: @revision
  end

  def test_get_index_with_no_revisions
    Comfy::Cms::Revision.delete_all
    r :get, comfy_admin_cms_site_page_translation_revisions_path(@site, @page, @translation)
    assert_response :redirect
    assert_redirected_to edit_comfy_admin_cms_site_page_translation_path(@site, @page, @translation)
  end

  def test_get_show
    r :get, comfy_admin_cms_site_page_translation_revision_path(@site, @page, @translation, @revision)
    assert_response :success
    assert assigns(:record)
    assert assigns(:revision)
    assert assigns(:record).is_a?(Comfy::Cms::Translation)
    assert_template :show
  end

  def test_get_show_for_invalid_record
    r :get, comfy_admin_cms_site_page_translation_revision_path(@site, @page, "invalid", @revision)
    assert_response :redirect
    assert_redirected_to comfy_admin_cms_site_pages_path(@site)
    assert_equal "Record Not Found", flash[:danger]
  end

  def test_get_show_failure
    r :get, comfy_admin_cms_site_page_translation_revision_path(@site, @page, @translation, "invalid")
    assert_response :redirect
    assert assigns(:record)
    assert_redirected_to edit_comfy_admin_cms_site_page_translation_path(@site, @page, assigns(:record))
    assert_equal "Revision Not Found", flash[:danger]
  end

  def test_revert
    assert_difference -> { @translation.revisions.count } do
      r :patch, revert_comfy_admin_cms_site_page_translation_revision_path(@site, @page, @translation, @revision)
      assert_response :redirect
      assert_redirected_to edit_comfy_admin_cms_site_page_translation_path(@site, @page, @translation)
      assert_equal "Content Reverted", flash[:success]

      @translation.reload

      assert_equal [{
        identifier: "content",
        tag:        "text",
        content:    "old content",
        datetime:   nil,
        boolean:    false
      }], @translation.fragments_attributes
    end
  end

end
