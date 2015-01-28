require_relative '../test_helper'

class JsVariablesIntegrationTest < ActionDispatch::IntegrationTest

  def test_redactor_js_variables
    site = comfy_cms_sites(:default)
    http_auth :get, comfy_admin_cms_site_pages_path(site)
    assert_response :success

    js_vars = <<-HTML.strip_heredoc
      <script>
        CMS.file_upload_path  = '#{comfy_admin_cms_site_files_path(site)}';
        CMS.pages_path        = '#{comfy_admin_cms_site_pages_path(site)}';
        CMS.locale            = 'en';
      </script>
    HTML

    assert response.body.match(js_vars)
  end

end
