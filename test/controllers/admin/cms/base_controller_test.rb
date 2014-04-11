require_relative '../../../test_helper'

class Admin::Cms::BaseControllerTest < ActionController::TestCase

  def test_get_jump
    get :jump
    assert_response :redirect
    assert_redirected_to admin_cms_site_pages_path(cms_sites(:default))
  end
  
  def test_get_jump_with_redirect_setting
    ComfortableMexicanSofa.config.admin_route_redirect { '/admin/sites' }
    get :jump
    assert_response :redirect
    assert_redirected_to '/admin/sites'
  end

  def test_get_jump_with_a_block
    ComfortableMexicanSofa.config.admin_route_redirect {
      if @site
        admin_cms_site_layouts_path @site
      else
        new_admin_cms_site_path
      end
    }
    get :jump
    assert_response :redirect
    assert_redirected_to "/admin/sites/#{Cms::Site.first.id}/layouts"
  end

end
