require File.dirname(__FILE__) + '/../test_helper'

class ViewHooksTest < ActionDispatch::IntegrationTest
  
  def test_hooks_rendering
    CmsAdmin::SitesController.append_view_path(File.expand_path('../fixtures/views', File.dirname(__FILE__)))
    ComfortableMexicanSofa::ViewHooks.add(:navigation, '/nav_hook')
    
    http_auth :get, cms_admin_sites_path
    assert_response :success
    assert_match /hook_content/, response.body
  end
  
  def test_hooks_rendering_with_no_hook
    ComfortableMexicanSofa::ViewHooks.remove(:navigation)
    
    http_auth :get, cms_admin_sites_path
    assert_response :success
    assert_no_match /hook_content/, response.body
  end
  
end