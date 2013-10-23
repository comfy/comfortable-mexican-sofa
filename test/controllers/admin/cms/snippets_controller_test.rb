require_relative '../../../test_helper'

class Admin::Cms::SnippetsControllerTest < ActionController::TestCase

  def test_get_index
    get :index, :site_id => cms_sites(:default)
    assert_response :success
    assert assigns(:snippets)
    assert_template :index
  end

  def test_get_index_with_no_snippets
    Cms::Snippet.delete_all
    get :index, :site_id => cms_sites(:default)
    assert_response :redirect
    assert_redirected_to :action => :new
  end
  
  def test_get_index_with_category
    category = cms_sites(:default).categories.create!(:label => 'Test Category', :categorized_type => 'Cms::Snippet')
    category.categorizations.create!(:categorized => cms_snippets(:default))
    
    get :index, :site_id => cms_sites(:default), :category => category.label
    assert_response :success
    assert assigns(:snippets)
    assert_equal 1, assigns(:snippets).count
    assert assigns(:snippets).first.categories.member? category
  end
  
  def test_get_index_with_category_invalid
    get :index, :site_id => cms_sites(:default), :category => 'invalid'
    assert_response :success
    assert assigns(:snippets)
    assert_equal 0, assigns(:snippets).count
  end

  def test_get_new
    site = cms_sites(:default)
    get :new, :site_id => site
    assert_response :success
    assert assigns(:snippet)
    assert_template :new
    assert_select "form[action=/admin/sites/#{site.id}/snippets]"
    assert_select "form[action='/admin/sites/#{site.id}/files?ajax=true']"
  end

  def test_get_edit
    snippet = cms_snippets(:default)
    get :edit, :site_id => snippet.site, :id => snippet
    assert_response :success
    assert assigns(:snippet)
    assert_template :edit
    assert_select "form[action=/admin/sites/#{snippet.site.id}/snippets/#{snippet.id}]"
  end
  
  def test_get_edit_with_params
    snippet = cms_snippets(:default)
    get :edit, :site_id => snippet.site, :id => snippet, :snippet => {:label => 'New Label'}
    assert_response :success
    assert assigns(:snippet)
    assert_equal 'New Label', assigns(:snippet).label
  end

  def test_get_edit_failure
    get :edit, :site_id => cms_sites(:default), :id => 'not_found'
    assert_response :redirect
    assert_redirected_to :action => :index
    assert_equal 'Snippet not found', flash[:error]
  end
  
  def test_create
    assert_difference 'Cms::Snippet.count' do
      post :create, :site_id => cms_sites(:default), :snippet => {
        :label      => 'Test Snippet',
        :identifier => 'test-snippet',
        :content    => 'Test Content'
      }
      assert_response :redirect
      snippet = Cms::Snippet.last
      assert_equal cms_sites(:default), snippet.site
      assert_redirected_to :action => :edit, :id => snippet
      assert_equal 'Snippet created', flash[:success]
    end
  end

  def test_creation_failure
    assert_no_difference 'Cms::Snippet.count' do
      post :create, :site_id => cms_sites(:default), :snippet => { }
      assert_response :success
      assert_template :new
      assert_equal 'Failed to create snippet', flash[:error]
    end
  end

  def test_update
    snippet = cms_snippets(:default)
    put :update, :site_id => snippet.site, :id => snippet, :snippet => {
      :label    => 'New-Snippet',
      :content  => 'New Content'
    }
    assert_response :redirect
    assert_redirected_to :action => :edit, :site_id => snippet.site, :id => snippet
    assert_equal 'Snippet updated', flash[:success]
    snippet.reload
    assert_equal 'New-Snippet', snippet.label
    assert_equal 'New Content', snippet.content
  end

  def test_update_failure
    snippet = cms_snippets(:default)
    put :update, :site_id => snippet.site, :id => snippet, :snippet => {
      :identifier => ''
    }
    assert_response :success
    assert_template :edit
    snippet.reload
    assert_not_equal '', snippet.identifier
    assert_equal 'Failed to update snippet', flash[:error]
  end

  def test_destroy
    assert_difference 'Cms::Snippet.count', -1 do
      delete :destroy, :site_id => cms_sites(:default), :id => cms_snippets(:default)
      assert_response :redirect
      assert_redirected_to :action => :index
      assert_equal 'Snippet deleted', flash[:success]
    end
  end
  
  def test_reorder
    snippet_one = cms_snippets(:default)
    snippet_two = cms_sites(:default).snippets.create!(
      :label      => 'test',
      :identifier => 'test'
    )
    assert_equal 0, snippet_one.position
    assert_equal 1, snippet_two.position

    post :reorder, :site_id => cms_sites(:default), :cms_snippet => [snippet_two.id, snippet_one.id]
    assert_response :success
    snippet_one.reload
    snippet_two.reload

    assert_equal 1, snippet_one.position
    assert_equal 0, snippet_two.position
  end

end