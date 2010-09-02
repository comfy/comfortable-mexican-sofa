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
    assert_select 'form[action=/cms-admin/pages]'
  end
  
  def test_get_new_as_child_page
    flunk
  end
  
  def test_get_edit
    flunk
  end
  
  def test_get_edit_failure
    flunk
  end
  
  def test_creation
    # assert_difference 'CmsPage.count' do
    #   post :create, :cms_page => {
    #     :label => 'New Page'
    #   }
    # end
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
  
  def test_get_form_blocks
    xhr :get, :form_blocks, :id => cms_pages(:default), :layout_id => cms_layouts(:nested).id
    assert_response :success
    assert assigns(:cms_page)
    assert_equal 2, assigns(:cms_page).cms_blocks.size
    assert_template 'form_blocks'
    
    xhr :get, :form_blocks, :id => cms_pages(:default), :layout_id => cms_layouts(:default).id
    assert_response :success
    assert assigns(:cms_page)
    assert_equal 3, assigns(:cms_page).cms_blocks.size
    assert_template 'form_blocks'
  end
  
  def test_get_form_blocks_for_new_page
    xhr :get, :form_blocks, :id => 0, :layout_id => cms_layouts(:default).id
    assert_response :success
    assert assigns(:cms_page)
    assert_equal 3, assigns(:cms_page).cms_blocks.size
    assert_template 'form_blocks'
  end
  
end