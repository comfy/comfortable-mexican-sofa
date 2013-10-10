require_relative '../../../test_helper'

class Admin::Cms::BaseControllerTest < ActionController::TestCase

  def test_get_jump
    get :jump
    assert_response :redirect
    assert_redirected_to admin_cms_site_pages_path(cms_sites(:default))
  end
  
  def test_get_jump_with_redirect_setting
    ComfortableMexicanSofa.config.admin_route_redirect = '/cms-admin/sites'
    get :jump
    assert_response :redirect
    assert_redirected_to '/cms-admin/sites'
  end

end