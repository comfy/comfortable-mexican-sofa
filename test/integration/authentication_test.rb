require File.dirname(__FILE__) + '/../test_helper'

class AuthenticationTest < ActionDispatch::IntegrationTest
  
  def test_get_with_unauthorized_access
    assert_equal 'ComfortableMexicanSofa::HttpAuth', ComfortableMexicanSofa.config.authentication
    get '/cms-admin/pages'
    assert_response :unauthorized
    get '/'
    assert_response :success
  end
  
  def test_get_with_authorized_access
    http_auth :get, '/cms-admin/pages'
    assert_response :success
  end
  
  def test_get_with_changed_default_config
    assert_equal 'ComfortableMexicanSofa::HttpAuth', ComfortableMexicanSofa.config.authentication
    ComfortableMexicanSofa::HttpAuth.username = 'newuser'
    ComfortableMexicanSofa::HttpAuth.password = 'newpass'
    http_auth :get, '/cms-admin/pages'
    assert_response :unauthorized
    http_auth :get, '/cms-admin/pages', {}, 'newuser', 'newpass'
    assert_response :success
  end
end