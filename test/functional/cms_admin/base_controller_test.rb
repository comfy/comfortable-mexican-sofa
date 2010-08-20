require  File.dirname(__FILE__) + '/../../test_helper'

class CmsAdmin::BaseControllerTest < ActionController::TestCase
  
  def setup
    http_auth
  end
  
  def test_index
    get :index
    assert_redirected_to cms_admin_pages_path
  end
  
  
end
