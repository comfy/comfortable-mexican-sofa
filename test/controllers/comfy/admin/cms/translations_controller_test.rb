require_relative '../../../../test_helper'

class Comfy::Admin::Cms::TranslationsControllerTest < ActionDispatch::IntegrationTest

  setup do
    @site         = comfy_cms_sites(:default)
    @page         = comfy_cms_pages(:default)
    @translation  = comfy_cms_snippets(:default)
  end

  def test_get_new
    r :get, new_comfy_admin_cms_site_page_translation_path(@site, @page)
    assert_response :success
    assert assigns(:translation)
    assert_template :new
    assert_select "form[action='/admin/sites/#{@site.id}/pages/#{@page.id}/translations']"
  end

  def test_get_edit
    r :get, edit_comfy_admin_cms_site_page_translation_path(@site, @page, @translation)
    assert_response :success
    assert assigns(:translation)
    assert_template :edit
    assert_select "form[action='/admin/sites/#{@site.id}/pages/#{@page.id}/translations/#{@translation.id}']"
  end

  def test_get_edit_failure
    r :get, edit_comfy_admin_cms_site_page_translation_path(@site, @page, "invalid")
    assert_response :redirect
    assert_redirected_to edit_comfy_admin_cms_site_page_path(@site, @page)
    assert_equal "Translation not found", flash[:danger]
  end

  def test_create
    assert_count_difference [Comfy::Cms::Translation] do
      path = comfy_admin_cms_site_page_translations_path(@site, @page)
      r :post, path, params: {translation: {
        locale: "es",
        label:  "Test Translation"
      }}
      assert_response :redirect
      translation = Comfy::Cms::Translation.last
      assert_equal @page, translation.page
      assert_redirected_to action: :edit, id: translation
      assert_equal "Translation created", flash[:success]
    end
  end

  def test_creation_failure
    assert_count_no_difference [Comfy::Cms::Translation] do
      path = comfy_admin_cms_site_page_translations_path(@site, @page)
      r :post, path, params: {translation: { }}
      assert_response :success
      assert_template :new
      assert_equal "Failed to create translation", flash[:danger]
    end
  end

  def test_update
    path = comfy_admin_cms_site_page_translation_path(@site, @page, @translation)
    r :put, path, params: {translation: {
      label: "Updated Translation"
    }}
    assert_response :redirect
    assert_redirected_to action: :edit, site_id: @site, page_id: @page, id: @translation
    assert_equal "Translation updated", flash[:success]
    @translation.reload
    assert_equal "Updated translation", @translation.label
  end

  def test_update_failure
    path = comfy_admin_cms_site_page_translation_path(@site, @page, @translation)
    r :put, path, params: {translation: {
      locale: ""
    }}
    assert_response :success
    assert_template :edit
    @translation.reload
    assert_not_equal "", @translation.identifier
    assert_equal 'Failed to update translation', flash[:danger]
  end

  def test_destroy
    assert_count_difference [Comfy::Cms::Snippet], -1 do
      r :delete, comfy_admin_cms_site_page_translation_path(@site, @page, @translation)
      assert_response :redirect
      assert_redirected_to comfy_admin_cms_site_page_path(@site, @page)
      assert_equal "Translation deleted", flash[:success]
    end
  end
end
