require  File.dirname(__FILE__) + '/../../test_helper'

class CmsAdmin::LayoutsControllerTest < ActionController::TestCase
  
  def setup
    http_auth
  end
  
  def test_get_index
    get :index
    assert_response :success
    assert assigns(:cms_layouts)
  end
  
  def test_get_new
    get :new
    assert_response :success
  end
  
  def test_get_edit
    get :edit, :id => cms_layouts(:default)
    assert_response :success
    assert assigns(:cms_layout)
  end
  
  def test_create
    assert_difference 'CmsLayout.count' do
      post :create, :cms_layout => {
        :label      => 'Test Layout',
        :parent_id  => '',
        :app_layout => '',
        :content    => 'Test content {{ cms_block:test_block:text }}'
      }
      assert_response :redirect
      assert_redirected_to edit_cms_admin_layout_path(assigns(:cms_layout))
      assert_equal 'Layout created', flash[:notice]
    end
  end
  
  def test_update
    layout = cms_layouts(:default)
    
    assert_difference 'CmsBlock.count', layout.cms_pages.count do
      put :update, :id => layout, :cms_layout => {
        :label => 'New Test Label',
        :content => '{{ cms_block:completely_new_block:string }}'
      }
      assert_response :redirect
      assert_redirected_to edit_cms_admin_layout_path(assigns(:cms_layout))
      assert_equal 'Layout updated', flash[:notice]
      
      layout.reload
      assert_equal 'New Test Label', layout.label
      assert_equal '{{ cms_block:completely_new_block:string }}', layout.content
    end
  end
  
  def test_destroy
    layout = cms_layouts(:default)
    assert !(layout_pages = layout.cms_pages).blank?
    
    assert_equal 1, layout.descendants.size
    
    assert_difference 'CmsLayout.count', -2 do
      assert_no_difference ['CmsPage.count', 'CmsBlock.count'] do
        delete :destroy, :id => layout
        assert_response :redirect
        assert_redirected_to cms_admin_layouts_path
        assert_equal 'Layout removed', flash[:notice]
        
        layout_pages.each do |page|
          assert !page.cms_layout
        end
      end
    end
  end
  
  def test_toggle
    assert !session[:cms_layout]
    # Expand
    post :toggle, :id => cms_layouts(:default)
    assert session[:cms_layout].include?(cms_layouts(:default).id)
    # Collapse
    post :toggle, :id => cms_layouts(:default)
    assert !session[:cms_layout].include?(cms_layouts(:default).id)
  end
end
