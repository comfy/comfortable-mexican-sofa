require  File.dirname(__FILE__) + '/../../test_helper'

class CmsAdmin::PagesControllerTest < ActionController::TestCase
  
  def test_get_index
    get :index
    assert_response :success
    assert assigns(:cms_pages)
    assert_template :index
  end
  
  def test_get_new
    get :new
    assert_response :success
    assert assigns(:cms_page)
    assert_template :new
    assert_select 'form[action=/cms_admin/pages]'
  end
  
  def test_get_edit
    flunk
  end
  
  def test_get_edit_failure
    flunk
  end
  
  def test_creation
    assert_difference 'CmsPage.count' do
      post :create, :cms_page => {
        :label => 'New Page'
      }
    end
    flunk
  end
  
  def test_creation_failure
    flunk
  end
  
  def test_update
    flunk
  end
  
  def test_update_failure
    flunk
  end
  
  def test_destroy
    flunk
  end
  
end