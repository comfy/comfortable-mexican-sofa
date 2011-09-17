require File.expand_path('../../test_helper', File.dirname(__FILE__))

class CmsAdmin::LayoutsControllerTest < ActionController::TestCase

  def test_get_index
    get :index, :site_id => cms_sites(:default)
    assert_response :success
    assert assigns(:layouts)
    assert_template :index
  end

  def test_get_index_with_no_layouts
    Cms::Layout.delete_all
    get :index, :site_id => cms_sites(:default) 
    assert_response :redirect
    assert_redirected_to :action => :new
  end

  def test_get_new
    site = cms_sites(:default)
    get :new, :site_id => site
    assert_response :success
    assert assigns(:layout)
    assert_equal '{{ cms:page:content:text }}', assigns(:layout).content
    assert_template :new
    assert_select "form[action=/cms-admin/sites/#{site.id}/layouts]"
  end

  def test_get_edit
    layout = cms_layouts(:default)
    get :edit, :site_id => cms_sites(:default), :id => layout
    assert_response :success
    assert assigns(:layout)
    assert_template :edit
    assert_select "form[action=/cms-admin/sites/#{layout.site.id}/layouts/#{layout.id}]"
  end

  def test_get_edit_failure
    get :edit, :site_id => cms_sites(:default), :id => 'not_found'
    assert_response :redirect
    assert_redirected_to :action => :index
    assert_equal 'Layout not found', flash[:error]
  end
  
  def test_creation
    assert_difference 'Cms::Layout.count' do
      post :create, :site_id => cms_sites(:default), :layout => {
        :label    => 'Test Layout',
        :slug     => 'test',
        :content  => 'Test {{cms:page:content}}'
      }
      assert_response :redirect
      layout = Cms::Layout.last
      assert_equal cms_sites(:default), layout.site
      assert_redirected_to :action => :edit, :site_id => layout.site, :id => layout
      assert_equal 'Layout created', flash[:notice]
    end
  end
  
  def test_creation_failure
    assert_no_difference 'Cms::Layout.count' do
      post :create, :site_id => cms_sites(:default), :layout => { }
      assert_response :success
      assert_template :new
      assert_equal 'Failed to create layout', flash[:error]
    end
  end
  
  def test_update
    layout = cms_layouts(:default)
    put :update, :site_id => cms_sites(:default), :id => layout, :layout => {
      :label    => 'New Label',
      :content  => 'New {{cms:page:content}}'
    }
    assert_response :redirect
    assert_redirected_to :action => :edit, :site_id => layout.site, :id => layout
    assert_equal 'Layout updated', flash[:notice]
    layout.reload
    assert_equal 'New Label', layout.label
    assert_equal 'New {{cms:page:content}}', layout.content
  end
  
  def test_update_failure
    layout = cms_layouts(:default)
    put :update, :site_id => cms_sites(:default), :id => layout, :layout => {
      :slug    => ''
    }
    assert_response :success
    assert_template :edit
    layout.reload
    assert_not_equal '', layout.slug
    assert_equal 'Failed to update layout', flash[:error]
  end
  
  def test_destroy
    assert_difference 'Cms::Layout.count', -1 do
      delete :destroy, :site_id => cms_sites(:default), :id => cms_layouts(:default)
      assert_response :redirect
      assert_redirected_to :action => :index
      assert_equal 'Layout deleted', flash[:notice]
    end
  end
  
  def test_reorder
    layout_one = cms_layouts(:default)
    layout_two = cms_sites(:default).layouts.create!(
      :label  => 'test',
      :slug   => 'test'
    )
    assert_equal 0, layout_one.position
    assert_equal 1, layout_two.position

    post :reorder, :site_id => cms_sites(:default), :cms_layout => [layout_two.id, layout_one.id]
    assert_response :success
    layout_one.reload
    layout_two.reload

    assert_equal 1, layout_one.position
    assert_equal 0, layout_two.position
  end

end