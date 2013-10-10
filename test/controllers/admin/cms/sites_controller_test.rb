require_relative '../../../test_helper'

class Admin::Cms::SitesControllerTest < ActionController::TestCase

  def test_get_index
    get :index
    assert_response :success
    assert assigns(:sites)
    assert_template :index
  end

  def test_get_index_with_no_sites
    Cms::Site.delete_all
    get :index
    assert_response :redirect
    assert_redirected_to :action => :new
  end

  def test_get_new
    get :new
    assert_response :success
    assert assigns(:site)
    assert_equal 'test.host', assigns(:site).hostname
    assert_template :new
    assert_select 'form[action=/admin/sites]'
  end

  def test_get_edit
    site = cms_sites(:default)
    get :edit, :id => site
    assert_response :success
    assert assigns(:site)
    assert_template :edit
    assert_select "form[action=/admin/sites/#{site.id}]"
  end

  def test_get_edit_failure
    get :edit, :id => 'not_found'
    assert_response :redirect
    assert_redirected_to :action => :index
    assert_equal 'Site not found', flash[:error]
  end
  
  def test_create
    assert_difference 'Cms::Site.count' do
      post :create, :site => {
        :label      => 'Test Site',
        :identifier => 'test-site',
        :hostname   => 'test.site.local'
      }
      assert_response :redirect
      site = Cms::Site.last
      assert_redirected_to admin_cms_site_layouts_path(site)
      assert_equal 'Site created', flash[:success]
    end
  end

  def test_creation_failure
    assert_no_difference 'Cms::Site.count' do
      post :create, :site => { }
      assert_response :success
      assert_template :new
      assert_equal 'Failed to create site', flash[:error]
    end
  end

  def test_update
    site = cms_sites(:default)
    put :update, :id => site, :site => {
      :label        => 'New Site',
      :hostname     => 'new.site.local',
      :locale       => 'es',
      :is_mirrored  => '1'
    }
    assert_response :redirect
    assert_redirected_to :action => :edit, :id => site
    assert_equal 'Site updated', flash[:success]
    site.reload
    assert_equal 'New Site', site.label
    assert_equal 'new.site.local', site.hostname
    assert_equal 'es', site.locale
    assert site.is_mirrored?
  end

  def test_update_failure
    site = cms_sites(:default)
    put :update, :id => site, :site => {
      :hostname => ''
    }
    assert_response :success
    assert_template :edit
    site.reload
    assert_not_equal '', site.hostname
    assert_equal 'Failed to update site', flash[:error]
  end

  def test_destroy
    assert_difference 'Cms::Site.count', -1 do
      delete :destroy, :id => cms_sites(:default)
      assert_response :redirect
      assert_redirected_to :action => :index
      assert_equal 'Site deleted', flash[:success]
    end
  end
end