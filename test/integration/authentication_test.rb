require_relative '../test_helper'

class AuthenticationIntegrationTest < ActionDispatch::IntegrationTest
  
  module TestLockPublicAuth
    def authenticate
      return redirect_to('/lockout')
    end
  end
  
  module TestUnlockPublicAuth
    def authenticate
      true
    end
  end
  
  def test_get_with_unauthorized_access
    assert_equal 'ComfortableMexicanSofa::DeviseAuth', ComfortableMexicanSofa.config.admin_auth
    delete '/admin/users/sign_out'
    assert_response :redirect
    get '/admin/sites'
    assert_response :redirect
    get '/'
    assert_response :success
  end
  
  def test_get_with_authorized_access
    http_auth :get, '/admin/sites'
    assert_response :success
  end
  
  # def test_get_with_changed_default_config
  #   assert_equal 'ComfortableMexicanSofa::DeviseAuth', ComfortableMexicanSofa.config.admin_auth
  #   ComfortableMexicanSofa::DeviseAuth.username = 'newuser'
  #   ComfortableMexicanSofa::DeviseAuth.password = 'newpass'
  #   http_auth :get, '/admin/sites'
  #   assert_response :unauthorized
  #   http_auth :get, '/admin/sites', {}, 'newuser', 'newpass'
  #   assert_response :success
  # end   
  
  def test_get_public_with_custom_auth
    Cms::ContentController.send :include, TestLockPublicAuth
    get '/'
    assert_response :redirect
    assert_redirected_to '/lockout'
    # reset auth module
    Cms::ContentController.send :include, TestUnlockPublicAuth
  end
end
