require File.expand_path('../test_helper', File.dirname(__FILE__))

class AuthenticationTest < ActionDispatch::IntegrationTest
  
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
    delete '/cms-admin/users/sign_out'
    get '/cms-admin/sites'
    assert_response 302
    get '/'
    assert_response :success
  end
  
  def test_get_with_authorized_access
    http_auth :get, '/cms-admin/sites'
    assert_response :success
  end
  
  def test_get_public_with_custom_auth
    CmsContentController.send :include, TestLockPublicAuth
    get '/'
    assert_response :redirect
    assert_redirected_to '/lockout'
    # reset auth module
    CmsContentController.send :include, TestUnlockPublicAuth
  end
end
