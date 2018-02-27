# frozen_string_literal: true

require_relative "../../../../../test_helper"

class Comfy::Admin::Cms::Revisions::SnippetControllerTest < ActionDispatch::IntegrationTest

  setup do
    @site     = comfy_cms_sites(:default)
    @snippet  = comfy_cms_snippets(:default)
    @revision = comfy_cms_revisions(:snippet)
  end

  def test_get_index
    r :get, comfy_admin_cms_site_snippet_revisions_path(@site, @snippet)
    assert_response :redirect
    assert_redirected_to action: :show, id: @revision
  end

  def test_get_index_with_no_revisions
    Comfy::Cms::Revision.delete_all
    r :get, comfy_admin_cms_site_snippet_revisions_path(@site, @snippet)
    assert_response :redirect
    assert_redirected_to edit_comfy_admin_cms_site_snippet_path(@site, @snippet)
  end

  def test_get_show
    r :get, comfy_admin_cms_site_snippet_revision_path(@site, @snippet, @revision)
    assert_response :success
    assert assigns(:record)
    assert assigns(:revision)
    assert assigns(:record).is_a?(Comfy::Cms::Snippet)
    assert_template :show
  end

  def test_get_show_for_invalid_record
    r :get, comfy_admin_cms_site_snippet_revision_path(@site, "invalid", @revision)
    assert_response :redirect
    assert_redirected_to comfy_admin_cms_site_snippets_path(@site)
    assert_equal "Record Not Found", flash[:danger]
  end

  def test_get_show_failure
    r :get, comfy_admin_cms_site_snippet_revision_path(@site, @snippet, "invalid")
    assert_response :redirect
    assert assigns(:record)
    assert_redirected_to edit_comfy_admin_cms_site_snippet_path(@site, assigns(:record))
    assert_equal "Revision Not Found", flash[:danger]
  end

  def test_revert
    assert_difference -> { @snippet.revisions.count } do
      r :patch, revert_comfy_admin_cms_site_snippet_revision_path(@site, @snippet, @revision)
      assert_response :redirect
      assert_redirected_to edit_comfy_admin_cms_site_snippet_path(@site, @snippet)
      assert_equal "Content Reverted", flash[:success]

      @snippet.reload
      assert_equal "revision content", @snippet.content
    end
  end

end
