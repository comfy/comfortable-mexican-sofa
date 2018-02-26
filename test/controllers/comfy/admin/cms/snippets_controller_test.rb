# frozen_string_literal: true

require_relative "../../../../test_helper"

class Comfy::Admin::Cms::SnippetsControllerTest < ActionDispatch::IntegrationTest

  setup do
    @site     = comfy_cms_sites(:default)
    @snippet  = comfy_cms_snippets(:default)
  end

  def test_get_index
    @site.snippets.create!(identifier: "other")

    r :get, comfy_admin_cms_site_snippets_path(site_id: @site)
    assert_response :success
    assert assigns(:snippets)
    assert_template :index
  end

  def test_get_index_with_no_snippets
    Comfy::Cms::Snippet.delete_all
    r :get, comfy_admin_cms_site_snippets_path(site_id: @site)
    assert_response :redirect
    assert_redirected_to action: :new
  end

  def test_get_index_with_category
    category = @site.categories.create!(
      label:            "Test Category",
      categorized_type: "Comfy::Cms::Snippet"
    )
    category.categorizations.create!(categorized: @snippet)

    r :get, comfy_admin_cms_site_snippets_path(site_id: @site), params: { categories: category.label }
    assert_response :success
    assert assigns(:snippets)
    assert_equal 1, assigns(:snippets).count
    assert assigns(:snippets).first.categories.member? category
  end

  def test_get_index_with_category_invalid
    r :get, comfy_admin_cms_site_snippets_path(site_id: @site), params: { categories: "invalid" }
    assert_response :success
    assert assigns(:snippets)
    assert_equal 0, assigns(:snippets).count
  end

  def test_get_new
    r :get, new_comfy_admin_cms_site_snippet_path(site_id: @site)
    assert_response :success
    assert assigns(:snippet)
    assert_template :new
    assert_select "form[action='/admin/sites/#{@site.id}/snippets']"
  end

  def test_get_edit
    r :get, edit_comfy_admin_cms_site_snippet_path(site_id: @site, id: @snippet)
    assert_response :success
    assert assigns(:snippet)
    assert_template :edit
    assert_select "form[action='/admin/sites/#{@site.id}/snippets/#{@snippet.id}']"
  end

  def test_get_edit_with_params
    r :get, edit_comfy_admin_cms_site_snippet_path(site_id: @site, id: @snippet), params: { snippet: {
      label: "New Label"
    } }
    assert_response :success
    assert assigns(:snippet)
    assert_equal "New Label", assigns(:snippet).label
  end

  def test_get_edit_failure
    r :get, edit_comfy_admin_cms_site_snippet_path(site_id: @site, id: "invalid")
    assert_response :redirect
    assert_redirected_to action: :index
    assert_equal "Snippet not found", flash[:danger]
  end

  def test_create
    assert_difference "Comfy::Cms::Snippet.count" do
      r :post, comfy_admin_cms_site_snippets_path(site_id: @site), params: { snippet: {
        label:      "Test Snippet",
        identifier: "test-snippet",
        content:    "Test Content"
      } }
      assert_response :redirect
      snippet = Comfy::Cms::Snippet.last
      assert_equal @site, snippet.site
      assert_redirected_to action: :edit, id: snippet
      assert_equal "Snippet created", flash[:success]
    end
  end

  def test_creation_failure
    assert_no_difference "Comfy::Cms::Snippet.count" do
      r :post, comfy_admin_cms_site_snippets_path(site_id: @site), params: { snippet: {} }
      assert_response :success
      assert_template :new
      assert_equal "Failed to create snippet", flash[:danger]
    end
  end

  def test_update
    r :put, comfy_admin_cms_site_snippet_path(site_id: @site, id: @snippet), params: { snippet: {
      label:   "New-Snippet",
      content: "New Content"
    } }
    assert_response :redirect
    assert_redirected_to action: :edit, site_id: @site, id: @snippet
    assert_equal "Snippet updated", flash[:success]
    @snippet.reload
    assert_equal "New-Snippet", @snippet.label
    assert_equal "New Content", @snippet.content
  end

  def test_update_failure
    r :put, comfy_admin_cms_site_snippet_path(site_id: @site, id: @snippet), params: { snippet: {
      identifier: ""
    } }
    assert_response :success
    assert_template :edit
    @snippet.reload
    assert_not_equal "", @snippet.identifier
    assert_equal "Failed to update snippet", flash[:danger]
  end

  def test_destroy
    assert_difference "Comfy::Cms::Snippet.count", -1 do
      r :delete, comfy_admin_cms_site_snippet_path(site_id: @site, id: @snippet)
      assert_response :redirect
      assert_redirected_to action: :index
      assert_equal "Snippet deleted", flash[:success]
    end
  end

  def test_reorder
    snippet_one = @snippet
    snippet_two = @site.snippets.create!(
      label:      "test",
      identifier: "test"
    )
    assert_equal 0, snippet_one.position
    assert_equal 1, snippet_two.position

    r :put, reorder_comfy_admin_cms_site_snippets_path(site_id: @site), params: {
      order: [snippet_two.id, snippet_one.id]
    }
    assert_response :success
    snippet_one.reload
    snippet_two.reload

    assert_equal 1, snippet_one.position
    assert_equal 0, snippet_two.position
  end

end
