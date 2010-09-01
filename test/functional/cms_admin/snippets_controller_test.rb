require  File.dirname(__FILE__) + '/../../test_helper'

class CmsAdmin::SnippetsControllerTest < ActionController::TestCase

  def test_index
    get :index
    assert_response :success
    assert_template 'index'
  end
  
  def test_new
    get :new
    assert_response :success
    assert_template 'new'
  end
  
  def test_create
    assert_difference 'CmsSnippet.count', 1 do
      post :create, :cms_snippet => cms_snippet_params
    end
    assert_equal 'Snippet saved', flash[:notice]
    assert_redirected_to edit_cms_admin_snippet_path(assigns(:cms_snippet))
  end
  
  def test_create_fails
    assert_no_difference 'CmsSnippet.count' do
      post :create, :cms_snippet => cms_snippet_params(:label => '')
    end
    assert_response :success
    assert_template 'new'
  end
  
  def test_edit
    get :edit, :id => cms_snippets(:default)
    assert_response :success
    assert_template 'edit'
  end
  
  def test_update
    snippet = cms_snippets(:default)
    put :update, :id => snippet, :cms_snippet => {:label => 'new-label'}
    assert_equal 'Snippet saved', flash[:notice]
    assert_redirected_to edit_cms_admin_snippet_path(assigns(:cms_snippet))
    assert_equal 'new-label', assigns(:cms_snippet).label
  end
  
  def test_update_fails
    snippet = cms_snippets(:default)
    put :update, :id => snippet, :cms_snippet => {:label => ''}
    assert_response :success
    assert_template 'edit'
    assert_equal 'default_snippet', snippet.label
  end
  
  def test_destroy
    assert_difference 'CmsSnippet.count', -1 do
      delete :destroy, :id => cms_snippets(:default)
    end
    assert_equal 'Snippet deleted', flash[:notice]
    assert_redirected_to cms_admin_snippets_path
  end

protected
  def cms_snippet_params(options = {})
    {
      :label => 'snippet-label',
      :content => 'Lorem ipsum dolor sit amet, consectetur adipisicing elit'
    }.merge(options)
  end
end