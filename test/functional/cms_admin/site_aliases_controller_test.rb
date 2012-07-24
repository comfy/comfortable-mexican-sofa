require File.expand_path('../../test_helper', File.dirname(__FILE__))

class CmsAdmin::SiteAliasesControllerTest < ActionController::TestCase

  def test_get_new
    site = cms_sites(:default)
    get :new, :site_id => site
    assert_response :success
    assert assigns(:site_alias)
    assert_template :new
    assert_select "form[action=/cms-admin/sites/#{site.id}/site_aliases]"
  end

  def test_get_edit
    site = cms_sites(:default)
    site_alias = cms_site_aliases(:default)
    get :edit, :site_id => cms_sites(:default), :id => site_alias
    assert_response :success
    assert assigns(:site)
    assert_template :edit
    assert_select "form[action=/cms-admin/sites/#{site.id}/site_aliases/#{site_alias.id}]"
  end

  def test_get_edit_failure
    get :edit, :id => 'not_found'
    assert_response :redirect
    assert_redirected_to :action => :index
    assert_equal 'Site alias not found', flash[:error]
  end

  def test_create
    assert_difference 'Cms::SiteAlias.count' do
      post :create, :site_id => cms_sites(:default), :site_alias => {
        :hostname   => 'test.site.local'
      }
      assert_response :redirect
      site = Cms::SiteAlias.last
      assert_redirected_to cms_admin_sites_path()
      assert_equal 'Site alias created', flash[:notice]
    end
  end

  def test_creation_failure
    assert_no_difference 'Cms::SiteAlias.count' do
      post :create, :site_id => cms_sites(:default), :site_alias => { }
      assert_response :success
      assert_template :new
      assert_equal 'Failed to create site alias', flash[:error]
    end
  end

  def test_update
    site_alias = cms_site_aliases(:default)
    put :update, :site_id => site_alias.site, :id => site_alias, :site_alias => {
      :hostname => 'new.site_alias.local'
    }
    assert_response :redirect
    assert_redirected_to :action => :edit, :site_id => cms_sites(:default), :id => site_alias
    assert_equal 'Site alias updated', flash[:notice]
    site_alias.reload
    assert_equal 'new.site_alias.local', site_alias.hostname
  end

  def test_update_failure
    site_alias = cms_site_aliases(:default)
    put :update, :site_id => site_alias.site, :id => site_alias, :site_alias => {
      :hostname => ''
    }
    assert_response :success
    assert_template :edit
    site_alias.reload
    assert_not_equal '', site_alias.hostname
    assert_equal 'Failed to update site alias', flash[:error]
  end

  def test_destroy
    assert_difference 'Cms::SiteAlias.count', -1 do
      delete :destroy, :id => cms_site_aliases(:default)
      assert_response :redirect
      assert_redirected_to cms_admin_sites_path()
      assert_equal 'Site alias deleted', flash[:notice]
    end
  end
end
