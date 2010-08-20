require  File.dirname(__FILE__) + '/../../test_helper'

class CmsAdmin::CategoriesControllerTest < ActionController::TestCase
  
  def setup
    http_auth
  end
    
  def test_get_index
    get :index
    assert_response :success
    assert assigns(:cms_categories)
  end
  
  def test_get_new
    get :new
    assert_response :success
  end
  
  def test_get_show
    get :show, :id => cms_categories(:category_2)
    assert_response :success
    assert assigns(:cms_category)
  end
  
  def test_get_edit
    get :edit, :id => cms_categories(:category_1)
    assert_response :success
    assert assigns(:cms_category)
  end
  
  def test_create
    assert_difference 'CmsCategory.count', 1 do
      post :create, :cms_category => {
        :label => 'Category 1',
        :description => 'This is a category',
      }
    end
    assert_redirected_to edit_cms_admin_category_path(assigns(:cms_category))
    assert_equal 'Category created', flash[:notice]
  end
  
  def test_create_fail
    #assert_no_difference 'CmsCategory.count' do
      post :create, :cms_category => {
        :label => '',
        :description => 'This is a category',
      }
    #end
    #assert_response :success
    #assert_template 'new'
    #assert assigns(:cms_category).errors[:label]
  end
  
  def test_update
    category = cms_categories(:category_1)
    put :update, :id => category, :cms_category => {
      :label => 'Category 2',
      :description => 'New Description'
    }
    assert_redirected_to edit_cms_admin_category_path(category)
    category.reload
    assert_equal 'Category 2', category.label
    assert_equal 'New Description', category.description
    assert_equal 'Category updated', flash[:notice]
  end
  
  def test_update_fail
    category = cms_categories(:category_1)
    put :update, :id => category, :cms_category => {
      :label => '',
      :description => 'New Description'
    }
    assert_response :success
    assert_template 'edit'
    assert assigns(:cms_category).errors[:label]
  end
  
  def test_destroy
    assert_difference 'CmsCategory.count', -1 do
      delete :destroy, :id => cms_categories(:category_1)
      assert_redirected_to cms_admin_categories_path
      assert_equal 'Category deleted', flash[:notice]
    end
  end
end

