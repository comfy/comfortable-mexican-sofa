require File.expand_path('../../test_helper', File.dirname(__FILE__))

class CmsAdmin::RevisionsControllerTest < ActionController::TestCase
  
  def test_get_index_for_layouts
    get :index, :layout_id => cms_layouts(:default)
    assert_response :redirect
    assert_redirected_to :action => :show, :id => cms_revisions(:layout)
  end
  
  def test_get_index_for_pages
    get :index, :page_id => cms_pages(:default)
    assert_response :redirect
    assert_redirected_to :action => :show, :id => cms_revisions(:page)
  end
  
  def test_get_index_for_snippets
    get :index, :snippet_id => cms_snippets(:default)
    assert_response :redirect
    assert_redirected_to :action => :show, :id => cms_revisions(:snippet)
  end
  
  def test_get_index_for_snippets_with_no_revisions
    Cms::Revision.delete_all
    get :index, :snippet_id => cms_snippets(:default)
    assert_response :redirect
    assert_redirected_to :action => :show, :id => 0
  end
  
  def test_get_show_for_layout
    get :show, :layout_id => cms_layouts(:default), :id => cms_revisions(:layout)
    assert_response :success
    assert assigns(:record)
    assert assigns(:revision)
    assert assigns(:record).is_a?(Cms::Layout)
    assert_template :show
  end
  
  def test_get_show_for_page
    get :show, :page_id => cms_pages(:default), :id => cms_revisions(:page)
    assert_response :success
    assert assigns(:record)
    assert assigns(:revision)
    assert assigns(:record).is_a?(Cms::Page)
    assert_template :show
  end
  
  def test_get_show_for_snippet
    get :show, :snippet_id => cms_snippets(:default), :id => cms_revisions(:snippet)
    assert_response :success
    assert assigns(:record)
    assert assigns(:revision)
    assert assigns(:record).is_a?(Cms::Snippet)
    assert_template :show
  end
  
  def test_get_show_for_bad_type
    get :show, :snippet_id => 'invalid', :id => cms_revisions(:snippet)
    assert_response :redirect
    assert_redirected_to cms_admin_path
    assert_equal 'Record Not Found', flash[:error]
  end
  
  def test_get_show_for_layout_failure
    get :show, :layout_id => cms_layouts(:default), :id => 'invalid'
    assert_response :redirect
    assert assigns(:record)
    assert_redirected_to edit_cms_admin_layout_path(assigns(:record))
    assert_equal 'Revision Not Found', flash[:error]
  end
  
  def test_get_show_for_page_failure
    get :show, :page_id => cms_pages(:default), :id => 'invalid'
    assert_response :redirect
    assert assigns(:record)
    assert_redirected_to edit_cms_admin_page_path(assigns(:record))
    assert_equal 'Revision Not Found', flash[:error]
  end
  
  def test_get_show_for_snippet_failure
    get :show, :snippet_id => cms_snippets(:default), :id => 'invalid'
    assert_response :redirect
    assert assigns(:record)
    assert_redirected_to edit_cms_admin_snippet_path(assigns(:record))
    assert_equal 'Revision Not Found', flash[:error]
  end
  
  def test_revert_for_layout
    layout = cms_layouts(:default)
    
    assert_difference 'layout.revisions.count' do 
      put :revert, :layout_id => layout, :id => cms_revisions(:layout)
      assert_response :redirect
      assert_redirected_to edit_cms_admin_layout_path(layout)
      assert_equal 'Content Reverted', flash[:notice]
      
      layout.reload
      assert_equal 'revision {{cms:page:default_page_text}}', layout.content
      assert_equal 'revision css', layout.css
      assert_equal 'revision js', layout.js
    end
  end
  
  def test_revert_for_page
    page = cms_pages(:default)
    
    assert_difference 'page.revisions.count' do
      put :revert, :page_id => page, :id => cms_revisions(:page)
      assert_response :redirect
      assert_redirected_to edit_cms_admin_page_path(page)
      assert_equal 'Content Reverted', flash[:notice]
      
      page.reload
      assert_equal [
        { :label => 'default_field_text', :content => 'revision field content'  },
        { :label => 'default_page_text',  :content => 'revision page content'   }
      ], page.blocks_attributes
    end
  end
  
  def test_revert_for_snippet
    snippet = cms_snippets(:default)
    
    assert_difference 'snippet.revisions.count' do
      put :revert, :snippet_id => snippet, :id => cms_revisions(:snippet)
      assert_response :redirect
      assert_redirected_to edit_cms_admin_snippet_path(snippet)
      assert_equal 'Content Reverted', flash[:notice]
      
      snippet.reload
      assert_equal 'revision content', snippet.content
    end
  end
  
end