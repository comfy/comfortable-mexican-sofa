require  File.dirname(__FILE__) + '/../../test_helper'

class CmsAdmin::PagesControllerTest < ActionController::TestCase
  
  def setup
    http_auth
  end
  
  def test_get_index
    get :index
    assert_response :success
    assert assigns(:cms_pages)
  end
  
  def test_get_new
    get :new
    assert_response :success
  end
  
  def test_get_edit
    get :edit, :id => cms_pages(:default)
    assert_response :success
    assert assigns(:cms_page)
  end
  
  def test_create
    assert_difference 'CmsPage.count' do
      assert_difference 'CmsBlock.count', 3 do
        post :create, :cms_page => {
          :label  => 'Test Page',
          :slug   => 'test_page',
          :cms_layout => cms_layouts(:default),
          :blocks => {
            :header   => { :content_string => 'Test Header' },
            :default  => { :content_text => 'Test Content' },
            :footer   => { :content_text => 'Test Footer' }
          }
        }
        assert_response :redirect
        assert_redirected_to edit_cms_admin_page_path(assigns(:cms_page))
        assert_equal 'Page created', flash[:notice]
        
        assert page = CmsPage.find_by_slug('test_page')
        assert_equal 'Test Header', page.cms_block_content(:header, :content_string)
        assert_equal 'Test Content', page.cms_block_content(:default, :content_text)
        assert_equal 'Test Footer', page.cms_block_content(:footer, :content_text)
      end
    end
  end
  
  def test_update
    page = cms_pages(:complex)
    
    assert_difference 'CmsBlock.count' do
      put :update, :id => page, :cms_page => {
        :label  => 'New Test Page',
        :slug   => 'new_test_page',
        :cms_layout => cms_layouts(:default),
        :blocks => {
          :header   => { :content_string => 'New Test Header' },
          :default  => { :content_text => 'New Test Content' },
          :footer   => { :content_text => 'New Test Footer' }
        }
      }
      assert_response :redirect
      assert_redirected_to edit_cms_admin_page_path(assigns(:cms_page))
      assert_equal 'Page updated', flash[:notice]
    
      assert page = CmsPage.find_by_slug('new_test_page')
      assert_equal 'New Test Header', page.cms_block_content(:header, :content_string)
      assert_equal 'New Test Content', page.cms_block_content(:default, :content_text)
      assert_equal 'New Test Footer', page.cms_block_content(:footer, :content_text)
      
      # old blocks are still there:
      assert !page.cms_block_content(:left_column, :content_text).blank?
      assert !page.cms_block_content(:right_column, :content_text).blank?
    end
  end
  
  def test_destroy
    page = cms_pages(:default)
    
    assert_difference 'CmsPage.count', -7 do
      assert_difference 'CmsBlock.count', -7 do
        delete :destroy, :id => page
        assert_response :redirect
        assert_redirected_to cms_admin_pages_path
        assert_equal 'Page removed', flash[:notice]
      end
    end
  end
  
  def test_preview_for_create
    assert_no_difference 'CmsPage.count' do
      assert_no_difference 'CmsBlock.count' do
        post :create, :preview  => 'Preview Button', :cms_page => {
          :label    => 'Test Page',
          :slug     => 'test_page',
          :cms_layout => cms_layouts(:default),
          :blocks => {
            :header   => { :content_string => 'Test Header' },
            :default  => { :content_text => 'Test Content' },
            :footer   => { :content_text => 'Test Footer' }
          }
        }
        assert_response :success
      end
    end
  end
  
  def test_preview_for_update
    page = cms_pages(:complex)
    
    assert_no_difference 'CmsBlock.count' do
      put :update, :preview => 'Preview Button', :id => page, :cms_page => {
        :label  => 'New Test Page',
        :slug   => 'new_test_page',
        :cms_layout => cms_layouts(:default),
        :blocks => {
          :header   => { :content_string => 'New Test Header' },
          :default  => { :content_text => 'New Test Content' },
          :footer   => { :content_text => 'New Test Footer' }
        }
      }
      assert_response :success
    end
  end
  
  def test_toggle
    assert !session[:cms_page]
    # Expand
    post :toggle, :id => cms_pages(:default)
    assert session[:cms_page].include?(cms_pages(:default).id)
    # Collapse
    post :toggle, :id => cms_pages(:default)
    assert !session[:cms_page].include?(cms_pages(:default).id)
  end
end
