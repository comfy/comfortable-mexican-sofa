# frozen_string_literal: true

require_relative "../test_helper"

class MetaVariablesIntegrationTest < ActionDispatch::IntegrationTest

  def test_redactor_js_variables
    site = comfy_cms_sites(:default)
    r :get, comfy_admin_cms_site_pages_path(site)
    assert_response :success

    assert_select "meta[name='cms-file-upload-path'][content='#{comfy_admin_cms_site_files_path(site)}']"
    assert_select "meta[name='cms-pages-path'][content='#{comfy_admin_cms_site_pages_path(site)}']"
    assert_select "meta[name='cms-locale'][content='en']"
  end

  def test_plupload_js_variables
    site = comfy_cms_sites(:default)
    r :get, comfy_admin_cms_site_files_path(site)
    assert_response :success

    assert_select "[data-cms-uploader-url]"
    assert_select "[data-cms-uploader-token-name]"
    assert_select "[data-cms-uploader-token-value]"
    assert_select "[data-cms-uploader-session-name]"
    assert_select "[data-cms-uploader-session-value]"
  end

end
