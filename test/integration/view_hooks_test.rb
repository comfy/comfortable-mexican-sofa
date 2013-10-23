require_relative '../test_helper'

class ViewHooksIntegrationTest < ActionDispatch::IntegrationTest

  def setup
    super
    login_as cms_users(:admin)
  end

  def teardown
    super
    ComfortableMexicanSofa::ViewHooks.remove(:navigation)
    sign_out
  end
  
  def test_hooks_rendering
    Admin::Cms::SitesController.append_view_path(File.expand_path('../fixtures/views', File.dirname(__FILE__)))
    ComfortableMexicanSofa::ViewHooks.add(:navigation, '/nav_hook')

    get admin_cms_sites_path
    assert_response :success
    assert_match /hook_content/, response.body
  end
  
  def test_hooks_rendering_with_multiples
    Admin::Cms::SitesController.append_view_path(File.expand_path('../fixtures/views', File.dirname(__FILE__)))
    ComfortableMexicanSofa::ViewHooks.add(:navigation, '/nav_hook')
    ComfortableMexicanSofa::ViewHooks.add(:navigation, '/nav_hook_2')
    
    get admin_cms_sites_path

    assert_response :success
    assert_match /hook_content/, response.body
    assert_match /<hook_content_2>/, response.body
  end

  def test_hooks_rendering_with_proper_order
    Admin::Cms::SitesController.append_view_path(File.expand_path('../fixtures/views', File.dirname(__FILE__)))
    ComfortableMexicanSofa::ViewHooks.add(:navigation, '/nav_hook_2', 0)
    ComfortableMexicanSofa::ViewHooks.add(:navigation, '/nav_hook', 1)
    
    get admin_cms_sites_path

    assert_response :success
    assert_match /<hook_content_2>hook_content/, response.body
  end
  
  def test_hooks_rendering_with_no_hook
    ComfortableMexicanSofa::ViewHooks.remove(:navigation)
    
    get admin_cms_sites_path

    assert_response :success
    assert_no_match /hook_content/, response.body
  end

end
