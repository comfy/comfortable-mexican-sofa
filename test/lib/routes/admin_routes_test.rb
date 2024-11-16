# frozen_string_literal: true

require_relative '../../test_helper'

class AdminRoutesTest < ActionDispatch::IntegrationTest
  def setup
    @site = comfy_cms_sites(:default)
  end

  def teardown
    Rails.application.reload_routes!
  end

  def test_cms_admin_routes
    assert_routing '/admin', controller: 'comfy/admin/cms/base', action: 'jump'
    assert_routing '/auth/identity/callback',
                   controller: 'comfy/cms/content',
                   action: 'show',
                   cms_path: 'auth/identity/callback'
  end
end
