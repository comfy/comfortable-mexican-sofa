# frozen_string_literal: true

require_relative "../../../../test_helper"

class Comfy::Admin::Cms::BaseControllerTest < ActionDispatch::IntegrationTest

  def test_get_jump
    r :get, comfy_admin_cms_path
    assert_response :redirect
    assert_redirected_to comfy_admin_cms_site_pages_path(comfy_cms_sites(:default))
  end

  def test_get_jump_with_redirect_setting
    ComfortableMexicanSofa.config.admin_route_redirect = "/cms-admin/sites"
    r :get, comfy_admin_cms_path
    assert_response :redirect
    assert_redirected_to "/cms-admin/sites"
  end

end
