require_relative '../../../../test_helper'

class Comfy::Admin::Cms::LayoutsControllerTest < ActionController::TestCase

  def test_get_index
    get :index, :site_id => comfy_cms_sites(:default)
    assert_response :success
    assert assigns(:layouts)
    assert_template :index
  end

  def test_get_index_with_no_layouts
    Comfy::Cms::Layout.delete_all
    get :index, :site_id => comfy_cms_sites(:default)
    assert_response :redirect
    assert_redirected_to :action => :new
  end

  def test_get_new
    site = comfy_cms_sites(:default)
    get :new, :site_id => site
    assert_response :success
    assert assigns(:layout)
    assert_equal '{{ cms:page:content:rich_text }}', assigns(:layout).content
    assert_template :new
    assert_select "form[action=/admin/sites/#{site.id}/layouts]"
  end

  def test_get_new_with_parent
    site    = comfy_cms_sites(:default)
    layout  = comfy_cms_layouts(:default)
    layout.update_column(:app_layout, 'application')
    get :new, :site_id => site, :parent_id => layout
    assert_response :success
    assert_equal layout.app_layout, assigns(:layout).app_layout
  end

  def test_get_edit
    layout = comfy_cms_layouts(:default)
    get :edit, :site_id => comfy_cms_sites(:default), :id => layout
    assert_response :success
    assert assigns(:layout)
    assert_template :edit
    assert_select "form[action=/admin/sites/#{layout.site.id}/layouts/#{layout.id}]"
  end

  def test_get_edit_failure
    get :edit, :site_id => comfy_cms_sites(:default), :id => 'not_found'
    assert_response :redirect
    assert_redirected_to :action => :index
    assert_equal 'Layout not found', flash[:danger]
  end

  def test_creation
    assert_difference 'Comfy::Cms::Layout.count' do
      post :create, :site_id => comfy_cms_sites(:default), :layout => {
        :label      => 'Test Layout',
        :identifier => 'test',
        :content    => 'Test {{cms:page:content}}'
      }
      assert_response :redirect
      layout = Comfy::Cms::Layout.last
      assert_equal comfy_cms_sites(:default), layout.site
      assert_redirected_to :action => :edit, :site_id => layout.site, :id => layout
      assert_equal 'Layout created', flash[:success]
    end
  end

  def test_creation_failure
    assert_no_difference 'Comfy::Cms::Layout.count' do
      post :create, :site_id => comfy_cms_sites(:default), :layout => { }
      assert_response :success
      assert_template :new
      assert_equal 'Failed to create layout', flash[:danger]
    end
  end

  def test_update
    layout = comfy_cms_layouts(:default)
    put :update, :site_id => comfy_cms_sites(:default), :id => layout, :layout => {
      :label    => 'New Label',
      :content  => 'New {{cms:page:content}}'
    }
    assert_response :redirect
    assert_redirected_to :action => :edit, :site_id => layout.site, :id => layout
    assert_equal 'Layout updated', flash[:success]
    layout.reload
    assert_equal 'New Label', layout.label
    assert_equal 'New {{cms:page:content}}', layout.content
  end

  def test_update_failure
    layout = comfy_cms_layouts(:default)
    put :update, :site_id => comfy_cms_sites(:default), :id => layout, :layout => {
      :identifier => ''
    }
    assert_response :success
    assert_template :edit
    layout.reload
    assert_not_equal '', layout.identifier
    assert_equal 'Failed to update layout', flash[:danger]
  end

  def test_destroy
    assert_difference 'Comfy::Cms::Layout.count', -1 do
      delete :destroy, :site_id => comfy_cms_sites(:default), :id => comfy_cms_layouts(:default)
      assert_response :redirect
      assert_redirected_to :action => :index
      assert_equal 'Layout deleted', flash[:success]
    end
  end

  def test_reorder
    layout_one = comfy_cms_layouts(:default)
    layout_two = comfy_cms_sites(:default).layouts.create!(
      :label      => 'test',
      :identifier => 'test'
    )
    assert_equal 0, layout_one.position
    assert_equal 1, layout_two.position

    put :reorder, :site_id => comfy_cms_sites(:default), :comfy_cms_layout => [layout_two.id, layout_one.id]
    assert_response :success
    layout_one.reload
    layout_two.reload

    assert_equal 1, layout_one.position
    assert_equal 0, layout_two.position
  end

end
