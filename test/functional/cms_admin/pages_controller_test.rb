require  File.dirname(__FILE__) + '/../../test_helper'

class CmsAdmin::PagesControllerTest < ActionController::TestCase
  
  def test_get_index
    get :index
    assert_response :success
    assert assigns(:cms_pages)
    assert_template :index
  end
  
  def test_get_index_with_no_pages
    CmsPage.delete_all
    get :index
    assert_response :redirect
    assert_redirected_to :action => :new
  end
  
  def test_get_new
    get :new
    assert_response :success
    assert assigns(:cms_page)
    assert_equal cms_layouts(:default), assigns(:cms_page).cms_layout
    
    assert_template :new
    assert_select 'form[action=/cms-admin/pages]'
  end
  
  def test_get_new_with_field_datetime
    cms_layouts(:default).update_attribute(:content, '{{cms:field:test_label:datetime}}')
    get :new
    assert_select "input[type='datetime'][name='cms_page[cms_blocks_attributes][][content]']"
    assert_select "input[type='hidden'][name='cms_page[cms_blocks_attributes][][label]'][value='test_label']"
  end
  
  def test_get_new_with_field_integer
    cms_layouts(:default).update_attribute(:content, '{{cms:field:test_label:integer}}')
    get :new
    assert_select "input[type='number'][name='cms_page[cms_blocks_attributes][][content]']"
    assert_select "input[type='hidden'][name='cms_page[cms_blocks_attributes][][label]'][value='test_label']"
  end
  
  def test_get_new_with_field_string
    cms_layouts(:default).update_attribute(:content, '{{cms:field:test_label}}')
    get :new
    assert_select "input[type='text'][name='cms_page[cms_blocks_attributes][][content]']"
    assert_select "input[type='hidden'][name='cms_page[cms_blocks_attributes][][label]'][value='test_label']"
  end
  
  def test_get_new_with_field_text
    cms_layouts(:default).update_attribute(:content, '{{cms:field:test_label:text}}')
    get :new
    assert_select "textarea[name='cms_page[cms_blocks_attributes][][content]']"
    assert_select "input[type='hidden'][name='cms_page[cms_blocks_attributes][][label]'][value='test_label']"
  end
  
  def test_get_new_with_page_datetime
    cms_layouts(:default).update_attribute(:content, '{{cms:page:test_label:datetime}}')
    get :new
    assert_select "input[type='datetime'][name='cms_page[cms_blocks_attributes][][content]']"
    assert_select "input[type='hidden'][name='cms_page[cms_blocks_attributes][][label]'][value='test_label']"
  end
  
  def test_get_new_with_page_integer
    cms_layouts(:default).update_attribute(:content, '{{cms:page:test_label:integer}}')
    get :new
    assert_select "input[type='number'][name='cms_page[cms_blocks_attributes][][content]']"
    assert_select "input[type='hidden'][name='cms_page[cms_blocks_attributes][][label]'][value='test_label']"
  end
  
  def test_get_new_with_page_string
    cms_layouts(:default).update_attribute(:content, '{{cms:page:test_label:string}}')
    get :new
    assert_select "input[type='text'][name='cms_page[cms_blocks_attributes][][content]']"
    assert_select "input[type='hidden'][name='cms_page[cms_blocks_attributes][][label]'][value='test_label']"
  end
  
  def test_get_new_with_page_text
    cms_layouts(:default).update_attribute(:content, '{{cms:page:test_label}}')
    get :new
    assert_select "textarea[name='cms_page[cms_blocks_attributes][][content]']"
    assert_select "input[type='hidden'][name='cms_page[cms_blocks_attributes][][label]'][value='test_label']"
  end
  
  def test_get_new_as_child_page
    get :new, :parent_id => cms_pages(:default)
    assert_response :success
    assert assigns(:cms_page)
    assert_equal cms_pages(:default), assigns(:cms_page).parent
    assert_template :new
  end
  
  def test_get_edit
    page = cms_pages(:default)
    get :edit, :id => page
    assert_response :success
    assert assigns(:cms_page)
    assert_template :edit
    assert_select "form[action=/cms-admin/pages/#{page.id}]"
    assert_select "input[name='cms_page[cms_blocks_attributes][][id]'][value='#{cms_blocks(:default_field_text).id}']"
    assert_select "input[name='cms_page[cms_blocks_attributes][][id]'][value='#{cms_blocks(:default_field_text).id}']"
  end
  
  def test_get_edit_failure
    get :edit, :id => 'not_found'
    assert_response :redirect
    assert_redirected_to :action => :index
    assert_equal 'Page not found', flash[:error]
  end
  
  def test_get_edit_with_blank_layout
    page = cms_pages(:default)
    page.update_attribute(:cms_layout_id, nil)
    get :edit, :id => page
    assert_response :success
    assert assigns(:cms_page)
    assert assigns(:cms_page).cms_layout
  end
  
  def test_creation
    assert_difference 'CmsPage.count' do
      assert_difference 'CmsBlock.count', 3 do
        post :create, :cms_page => {
          :label          => 'Test Page',
          :slug           => 'test-page',
          :parent_id      => cms_pages(:default).id,
          :cms_layout_id  => cms_layouts(:default).id,
          :cms_blocks_attributes => [
            { :label    => 'content',
              :content  => 'content content' },
            { :label    => 'title',
              :content  => 'title content' },
            { :label    => 'number',
              :content  => '999' }
          ]
        }
        assert_response :redirect
        page = CmsPage.last
        assert_equal cms_sites(:default), page.cms_site
        assert_redirected_to :action => :edit, :id => page
        assert_equal 'Page saved', flash[:notice]
      end
    end
  end
  
  def test_creation_failure
    assert_no_difference ['CmsPage.count', 'CmsBlock.count'] do
      post :create, :cms_page => {
        :cms_layout_id  => cms_layouts(:default).id,
        :cms_blocks_attributes => [
          { :label    => 'content',
            :content  => 'content content' },
          { :label    => 'title',
            :content  => 'title content' },
          { :label    => 'number',
            :content  => '999' }
        ]
      }
      assert_response :success
      page = assigns(:cms_page)
      assert_equal 3, page.cms_blocks.size
      assert_equal ['content content', 'title content', '999'], page.cms_blocks.collect{|b| b.content}
      assert_template :new
      assert_equal 'Failed to create page', flash[:error]
    end
  end
  
  def test_update
    page = cms_pages(:default)
    assert_no_difference 'CmsBlock.count' do
      put :update, :id => page, :cms_page => {
        :label => 'Updated Label'
      }
      page.reload
      assert_response :redirect
      assert_redirected_to :action => :edit, :id => page
      assert_equal 'Page updated', flash[:notice]
      assert_equal 'Updated Label', page.label
    end
  end
  
  def test_update_with_layout_change
    page = cms_pages(:default)
    assert_difference 'CmsBlock.count', 1 do
      put :update, :id => page, :cms_page => {
        :label => 'Updated Label',
        :cms_layout_id => cms_layouts(:nested).id,
        :cms_blocks_attributes => [
          { :label    => 'content',
            :content  => 'new_page_text_content',
            :id       => cms_blocks(:default_page_text).id },
          { :label    => 'header',
            :content  => 'new_page_string_content' }
        ]
      }
      page.reload
      assert_response :redirect
      assert_redirected_to :action => :edit, :id => page
      assert_equal 'Page updated', flash[:notice]
      assert_equal 'Updated Label', page.label
      assert_equal ['new_page_text_content', 'default_field_text_content', 'new_page_string_content'], page.cms_blocks.collect{|b| b.content}
    end
  end
  
  def test_update_failure
    put :update, :id => cms_pages(:default), :cms_page => {
      :label => ''
    }
    assert_response :success
    assert_template :edit
    assert assigns(:cms_page)
    assert_equal 'Failed to update page', flash[:error]
  end
  
  def test_destroy
    assert_difference 'CmsPage.count', -2 do
      assert_difference 'CmsBlock.count', -2 do
        delete :destroy, :id => cms_pages(:default)
        assert_response :redirect
        assert_redirected_to :action => :index
        assert_equal 'Page deleted', flash[:notice]
      end
    end
  end
  
  def test_get_form_blocks
    xhr :get, :form_blocks, :id => cms_pages(:default), :layout_id => cms_layouts(:nested).id
    assert_response :success
    assert assigns(:cms_page)
    assert_equal 2, assigns(:cms_page).cms_tags.size
    assert_template :form_blocks
    
    xhr :get, :form_blocks, :id => cms_pages(:default), :layout_id => cms_layouts(:default).id
    assert_response :success
    assert assigns(:cms_page)
    assert_equal 4, assigns(:cms_page).cms_tags.size
    assert_template :form_blocks
  end
  
  def test_get_form_blocks_for_new_page
    xhr :get, :form_blocks, :id => 0, :layout_id => cms_layouts(:default).id
    assert_response :success
    assert assigns(:cms_page)
    assert_equal 3, assigns(:cms_page).cms_tags.size
    assert_template :form_blocks
  end
  
end