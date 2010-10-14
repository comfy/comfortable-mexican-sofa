require File.dirname(__FILE__) + '/../test_helper'

class AuthenticationTest < ActionDispatch::IntegrationTest
  
  def test_get_with_unauthorized_access
    assert_equal 'CmsHttpAuthentication', ComfortableMexicanSofa.config.authentication
    get '/cms-admin/pages'
    assert_response :unauthorized
    get '/'
    assert_response :success
  end
  
  def test_get_with_authorized_access
    get '/cms-admin/pages', {}, {'HTTP_AUTHORIZATION' => "Basic #{Base64.encode64('username:password')}"}
    assert_response :success
  end
  
  def test_get_with_changed_default_config
    assert_equal 'CmsHttpAuthentication', ComfortableMexicanSofa.config.authentication
    CmsHttpAuthentication.username = 'newuser'
    CmsHttpAuthentication.password = 'newpass'
    get '/cms-admin/pages', {}, {'HTTP_AUTHORIZATION' => "Basic #{Base64.encode64('username:password')}"}
    assert_response :unauthorized
    get '/cms-admin/pages', {}, {'HTTP_AUTHORIZATION' => "Basic #{Base64.encode64('newuser:newpass')}"}
    assert_response :success
  end
  
end