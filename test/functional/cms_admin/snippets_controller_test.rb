require 'test_helper'

class CmsAdmin::SnippetsControllerTest < ActionController::TestCase

  def setup
    #http_auth
  end

  def test_get_index
    get :index
    assert_response :success
    assert assigns(:cms_snippets)
  end
  
  def test_get_new
    get :new
    assert_response :success
  end
  
  def test_create
    assert_difference 'CmsSnippet.count' do
      post :create, :cms_snippet => cms_snippet_params
      assert_redirected_to edit_cms_admin_snippet_path(assigns(:cms_snippet))
      assert_equal 'Snippet created', flash[:notice]
    end
  end
  
  def test_get_edit
    get :edit, :id => cms_snippets(:default)
    assert_response :success
    assert assigns(:cms_snippet)
  end
  
  def test_update
    snippet = cms_snippets(:default)
    
    put :update, :id => snippet, :cms_snippet => {
      :label    => 'new_test_label',
      :content  => 'new test content'
    }
    assert_redirected_to edit_cms_admin_snippet_path(snippet)
    assert_equal 'Snippet updated', flash[:notice]
      
    snippet.reload
    assert_equal 'new_test_label', snippet.label
    assert_equal 'new test content', snippet.content
  end
  
  def test_destroy
    assert_difference 'CmsSnippet.count', -1 do
      delete :destroy, :id => cms_snippets(:default)
      assert_redirected_to cms_admin_snippets_path
      assert_equal 'Snippet removed', flash[:notice]
    end
  end

private
  def cms_snippet_params(options = {})
    {
      :label    => 'test_snippet',
      :content  => 'test content'
    }.merge(options)
  end
end
