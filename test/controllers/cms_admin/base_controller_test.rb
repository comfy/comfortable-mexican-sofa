require File.expand_path('../../test_helper', File.dirname(__FILE__))

class CmsAdmin::BaseControllerTest < ActionController::TestCase

  def test_get_jump
    get :jump
    assert_response :redirect
    assert_redirected_to cms_admin_site_pages_path(cms_sites(:default))
  end
  
  def test_get_jump_with_redirect_setting
    ComfortableMexicanSofa.config.admin_route_redirect = '/cms-admin/sites'
    get :jump
    assert_response :redirect
    assert_redirected_to '/cms-admin/sites'
  end

end