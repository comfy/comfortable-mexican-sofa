require File.expand_path('../../test_helper', File.dirname(__FILE__))

class CmsAdmin::PagesControllerTest < ActionController::TestCase

  def test_get_index
    get :index
    assert_response :success
    assert assigns(:cms_pages)
    assert_template :index
  end

  def test_get_index_with_no_pages
    Cms::Page.delete_all
    get :index
    assert_response :redirect
    assert_redirected_to :action => :new
  end

  def test_get_new
    get :new
    assert_response :success
    assert assigns(:cms_page)
    assert_equal cms_layouts(:default), assigns(:cms_page).layout
    assert_template :new
    assert_select 'form[action=/cms-admin/pages]'
  end

  def test_get_new_with_field_datetime
    cms_layouts(:default).update_attribute(:content, '{{cms:field:test_label:datetime}}')
    get :new
    assert_select "input[type='datetime'][name='cms_page[blocks_attributes][][content]']"
    assert_select "input[type='hidden'][name='cms_page[blocks_attributes][][label]'][value='test_label']"
  end

  def test_get_new_with_field_integer
    cms_layouts(:default).update_attribute(:content, '{{cms:field:test_label:integer}}')
    get :new
    assert_select "input[type='number'][name='cms_page[blocks_attributes][][content]']"
    assert_select "input[type='hidden'][name='cms_page[blocks_attributes][][label]'][value='test_label']"
  end

  def test_get_new_with_field_string
    cms_layouts(:default).update_attribute(:content, '{{cms:field:test_label}}')
    get :new
    assert_select "input[type='text'][name='cms_page[blocks_attributes][][content]']"
    assert_select "input[type='hidden'][name='cms_page[blocks_attributes][][label]'][value='test_label']"
  end

  def test_get_new_with_field_text
    cms_layouts(:default).update_attribute(:content, '{{cms:field:test_label:text}}')
    get :new
    assert_select "textarea[name='cms_page[blocks_attributes][][content]']"
    assert_select "input[type='hidden'][name='cms_page[blocks_attributes][][label]'][value='test_label']"
  end

  def test_get_new_with_page_datetime
    cms_layouts(:default).update_attribute(:content, '{{cms:page:test_label:datetime}}')
    get :new
    assert_select "input[type='datetime'][name='cms_page[blocks_attributes][][content]']"
    assert_select "input[type='hidden'][name='cms_page[blocks_attributes][][label]'][value='test_label']"
  end

  def test_get_new_with_page_integer
    cms_layouts(:default).update_attribute(:content, '{{cms:page:test_label:integer}}')
    get :new
    assert_select "input[type='number'][name='cms_page[blocks_attributes][][content]']"
    assert_select "input[type='hidden'][name='cms_page[blocks_attributes][][label]'][value='test_label']"
  end

  def test_get_new_with_page_string
    cms_layouts(:default).update_attribute(:content, '{{cms:page:test_label:string}}')
    get :new
    assert_select "input[type='text'][name='cms_page[blocks_attributes][][content]']"
    assert_select "input[type='hidden'][name='cms_page[blocks_attributes][][label]'][value='test_label']"
  end

  def test_get_new_with_page_text
    cms_layouts(:default).update_attribute(:content, '{{cms:page:test_label}}')
    get :new
    assert_select "textarea[name='cms_page[blocks_attributes][][content]']"
    assert_select "input[type='hidden'][name='cms_page[blocks_attributes][][label]'][value='test_label']"
  end

  def test_get_new_with_rich_page_text
    cms_layouts(:default).update_attribute(:content, '{{cms:page:test_label:rich_text}}')
    get :new
    assert_select "textarea[name='cms_page[blocks_attributes][][content]']"
    assert_select "input[type='hidden'][name='cms_page[blocks_attributes][][label]'][value='test_label']"
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
  end

  def test_get_edit_failure
    get :edit, :id => 'not_found'
    assert_response :redirect
    assert_redirected_to :action => :index
    assert_equal 'Page not found', flash[:error]
  end

  def test_get_edit_with_blank_layout
    page = cms_pages(:default)
    page.update_attribute(:layout_id, nil)
    get :edit, :id => page
    assert_response :success
    assert assigns(:cms_page)
    assert assigns(:cms_page).layout
  end
  
  def test_creation
    assert_difference 'Cms::Page.count' do
      assert_difference 'Cms::Block.count', 2 do
        post :create, :cms_page => {
          :label          => 'Test Page',
          :slug           => 'test-page',
          :parent_id      => cms_pages(:default).id,
          :layout_id      => cms_layouts(:default).id,
          :blocks_attributes => [
            { :label    => 'default_page_text',
              :content  => 'content content' },
            { :label    => 'default_field_text',
              :content  => 'title content' }
          ]
        }, :commit => 'Create Page'
        assert_response :redirect
        page = Cms::Page.last
        assert_equal cms_sites(:default), page.site
        assert_redirected_to :action => :edit, :id => page
        assert_equal 'Page saved', flash[:notice]
      end
    end
  end
  
  def test_creation_failure
    assert_no_difference ['Cms::Page.count', 'Cms::Block.count'] do
      post :create, :cms_page => {
        :layout_id => cms_layouts(:default).id,
        :blocks_attributes => [
          { :label    => 'default_page_text',
            :content  => 'content content' },
          { :label    => 'default_field_text',
            :content  => 'title content' }
        ]
      }
      assert_response :success
      page = assigns(:cms_page)
      assert_equal 2, page.blocks.size
      assert_equal ['content content', 'title content'], page.blocks.collect{|b| b.content}
      assert_template :new
      assert_equal 'Failed to create page', flash[:error]
    end
  end

  def test_update
    page = cms_pages(:default)
    assert_no_difference 'Cms::Block.count' do
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
    assert_difference 'Cms::Block.count', 2 do
      put :update, :id => page, :cms_page => {
        :label      => 'Updated Label',
        :layout_id  => cms_layouts(:nested).id,
        :blocks_attributes => [
          { :label    => 'content',
            :content  => 'new_page_text_content' },
          { :label    => 'header',
            :content  => 'new_page_string_content' }
        ]
      }
      page.reload
      assert_response :redirect
      assert_redirected_to :action => :edit, :id => page
      assert_equal 'Page updated', flash[:notice]
      assert_equal 'Updated Label', page.label
      assert_equal ['content', 'default_field_text', 'default_page_text', 'header'], page.blocks.collect{|b| b.label}
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
    assert_difference 'Cms::Page.count', -2 do
      assert_difference 'Cms::Block.count', -2 do
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
    assert_equal 2, assigns(:cms_page).tags.size
    assert_template :form_blocks

    xhr :get, :form_blocks, :id => cms_pages(:default), :layout_id => cms_layouts(:default).id
    assert_response :success
    assert assigns(:cms_page)
    assert_equal 4, assigns(:cms_page).tags.size
    assert_template :form_blocks
  end

  def test_get_form_blocks_for_new_page
    xhr :get, :form_blocks, :id => 0, :layout_id => cms_layouts(:default).id
    assert_response :success
    assert assigns(:cms_page)
    assert_equal 3, assigns(:cms_page).tags.size
    assert_template :form_blocks
  end

  def test_creation_preview
    assert_no_difference 'Cms::Page.count' do
      post :create, :preview => 'Preview', :cms_page => {
        :label      => 'Test Page',
        :slug       => 'test-page',
        :parent_id  => cms_pages(:default).id,
        :layout_id  => cms_layouts(:default).id,
        :blocks_attributes => [
          { :label    => 'default_page_text',
            :content  => 'preview content' }
        ]
      }
      assert_response :success
      assert_match /preview content/, response.body
    end
  end

  def test_update_preview
    page = cms_pages(:default)
    assert_no_difference 'Cms::Page.count' do
      put :update, :preview => 'Preview', :id => page, :cms_page => {
        :label => 'Updated Label',
        :blocks_attributes => [
          { :label    => 'default_page_text',
            :content  => 'preview content',
            :id       => cms_blocks(:default_page_text).id}
        ]
      }
      assert_response :success
      assert_match /preview content/, response.body
      page.reload
      assert_not_equal 'Updated Label', page.label
    end
  end

  def test_get_new_with_no_layout
    Cms::Layout.destroy_all
    get :new
    assert_response :redirect
    assert_redirected_to new_cms_admin_layout_path
    assert_equal 'No Layouts found. Please create one.', flash[:error]
  end

  def test_get_edit_with_no_layout
    Cms::Layout.destroy_all
    page = cms_pages(:default)
    get :edit, :id => page
    assert_response :redirect
    assert_redirected_to new_cms_admin_layout_path
    assert_equal 'No Layouts found. Please create one.', flash[:error]
  end

  def test_get_toggle_branch
    page = cms_pages(:default)
    get :toggle_branch, :id => page, :format => :js
    assert_response :success
    assert_equal [page.id.to_s], session[:cms_page_tree]

    get :toggle_branch, :id => page, :format => :js
    assert_response :success
    assert_equal [], session[:cms_page_tree]
  end

  def test_reorder
    page_one = cms_pages(:child)
    page_two = cms_sites(:default).pages.create!(
      :parent => cms_pages(:default),
      :layout => cms_layouts(:default),
      :label  => 'test',
      :slug   => 'test'
    )
    assert_equal 0, page_one.position
    assert_equal 1, page_two.position

    post :reorder, :cms_page => [page_two.id, page_one.id]
    assert_response :success
    page_one.reload
    page_two.reload

    assert_equal 1, page_one.position
    assert_equal 0, page_two.position
  end

end