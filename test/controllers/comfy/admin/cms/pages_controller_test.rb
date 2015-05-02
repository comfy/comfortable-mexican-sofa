require_relative '../../../../test_helper'

class Comfy::Admin::Cms::PagesControllerTest < ActionController::TestCase

  def setup
    @site = comfy_cms_sites(:default)
  end

  def test_get_index
    get :index, :site_id => @site
    assert_response :success
    assert assigns(:pages)
    assert_template :index
  end

  def test_get_index_with_no_pages
    Comfy::Cms::Page.delete_all
    get :index, :site_id => @site
    assert_response :redirect
    assert_redirected_to :action => :new
  end

  def test_get_index_with_category
    category = @site.categories.create!(
      :label            => 'Test Category',
      :categorized_type => 'Comfy::Cms::Page'
    )
    category.categorizations.create!(:categorized => comfy_cms_pages(:child))

    get :index, :site_id => @site, :category => category.label
    assert_response :success
    assert assigns(:pages)
    assert_equal 1, assigns(:pages).count
    assert assigns(:pages).first.categories.member? category
  end

  def test_get_index_with_category_invalid
    get :index, :site_id => @site, :category => 'invalid'
    assert_response :success
    assert assigns(:pages)
    assert_equal 0, assigns(:pages).count
  end

  def test_get_index_with_toggle
    @site.pages.create!(
      :label  => 'test',
      :slug   => 'test',
      :parent => comfy_cms_pages(:child),
      :layout => comfy_cms_layouts(:default)
    )
    get :index, :site_id => @site
    assert_response :success
  end

  def test_get_links_with_redactor
    get :index, :site_id => @site, :source => 'redactor'
    assert_response :success

    assert_equal [
      {'name' => 'Select page...',  'url' => false},
      {'name' => 'Default Page',    'url' => '/'},
      {'name' => '. . Child Page',  'url' => '/child-page'}
    ], JSON.parse(response.body)
  end

  def test_get_new
    get :new, :site_id => @site
    assert_response :success
    assert assigns(:page)
    assert_equal comfy_cms_layouts(:default), assigns(:page).layout
    assert_template :new
    assert_select "form[action='/admin/sites/#{@site.id}/pages']"
    assert_select "select[data-url='/admin/sites/#{@site.id}/pages/0/form_blocks']"
  end

  def test_get_new_with_field_datetime
    comfy_cms_layouts(:default).update_columns(:content =>'{{cms:field:test_label:datetime}}')
    get :new, :site_id => @site
    assert_response :success
    assert_select "input[type='text'][name='page[blocks_attributes][0][content]'][data-cms-datetime]"
    assert_select "input[type='hidden'][name='page[blocks_attributes][0][identifier]'][value='test_label']"
  end

  def test_get_new_with_field_integer
    comfy_cms_layouts(:default).update_columns(:content => '{{cms:field:test_label:integer}}')
    get :new, :site_id => @site
    assert_response :success
    assert_select "input[type='number'][name='page[blocks_attributes][0][content]']"
    assert_select "input[type='hidden'][name='page[blocks_attributes][0][identifier]'][value='test_label']"
  end

  def test_get_new_with_field_string
    comfy_cms_layouts(:default).update_columns(:content => '{{cms:field:test_label:string}}')
    get :new, :site_id => @site
    assert_response :success
    assert_select "input[type='text'][name='page[blocks_attributes][0][content]']"
    assert_select "input[type='hidden'][name='page[blocks_attributes][0][identifier]'][value='test_label']"
  end

  def test_get_new_with_field_text
    comfy_cms_layouts(:default).update_columns(:content => '{{cms:field:test_label:text}}')
    get :new, :site_id => @site
    assert_response :success
    assert_select "textarea[name='page[blocks_attributes][0][content]'][data-cms-cm-mode='text/html']"
    assert_select "input[type='hidden'][name='page[blocks_attributes][0][identifier]'][value='test_label']"
  end

  def test_get_new_with_field_rich_text
    comfy_cms_layouts(:default).update_columns(:content => '{{cms:field:test_label:rich_text}}')
    get :new, :site_id => @site
    assert_response :success
    assert_select "textarea[name='page[blocks_attributes][0][content]'][data-cms-rich-text]"
    assert_select "input[type='hidden'][name='page[blocks_attributes][0][identifier]'][value='test_label']"
  end

  def test_get_new_with_page_datetime
    comfy_cms_layouts(:default).update_columns(:content => '{{cms:page:test_label:datetime}}')
    get :new, :site_id => @site
    assert_response :success
    assert_select "input[type='text'][name='page[blocks_attributes][0][content]'][data-cms-datetime]"
    assert_select "input[type='hidden'][name='page[blocks_attributes][0][identifier]'][value='test_label']"
  end

  def test_get_new_with_page_integer
    comfy_cms_layouts(:default).update_columns(:content => '{{cms:page:test_label:integer}}')
    get :new, :site_id => @site
    assert_response :success
    assert_select "input[type='number'][name='page[blocks_attributes][0][content]']"
    assert_select "input[type='hidden'][name='page[blocks_attributes][0][identifier]'][value='test_label']"
  end

  def test_get_new_with_page_string
    comfy_cms_layouts(:default).update_columns(:content => '{{cms:page:test_label:string}}')
    get :new, :site_id => @site
    assert_response :success
    assert_select "input[type='text'][name='page[blocks_attributes][0][content]']"
    assert_select "input[type='hidden'][name='page[blocks_attributes][0][identifier]'][value='test_label']"
  end

  def test_get_new_with_page_text
    comfy_cms_layouts(:default).update_columns(:content => '{{cms:page:test_label}}')
    get :new, :site_id => @site
    assert_response :success
    assert_select "textarea[name='page[blocks_attributes][0][content]'][data-cms-cm-mode='text/html']"
    assert_select "input[type='hidden'][name='page[blocks_attributes][0][identifier]'][value='test_label']"
  end

  def test_get_new_with_page_file
    comfy_cms_layouts(:default).update_columns(:content => '{{cms:page_file:test_label}}')
    get :new, :site_id => @site
    assert_response :success
    assert_select "input[type='file'][name='page[blocks_attributes][0][content]']"
    assert_select "input[type='hidden'][name='page[blocks_attributes][0][identifier]'][value='test_label']"
  end

  def test_get_new_with_page_files
    comfy_cms_layouts(:default).update_columns(:content => '{{cms:page_files:test_label}}')
    get :new, :site_id => @site
    assert_response :success
    assert_select "input[type='file'][name='page[blocks_attributes][0][content][]'][multiple=multiple]"
    assert_select "input[type='hidden'][name='page[blocks_attributes][0][identifier]'][value='test_label']"
  end

  def test_get_new_with_collection
    snippet = comfy_cms_snippets(:default)
    comfy_cms_layouts(:default).update_columns(:content => '{{cms:collection:snippet:comfy/cms/snippet}}')
    get :new, :site_id => @site
    assert_response :success
    assert_select "select[name='page[blocks_attributes][0][content]']" do
      assert_select "option[value='']", :html => '---- Select Comfy/Cms/Snippet ----'
      assert_select "option[value='#{snippet.id}']", :html => snippet.label
    end
    assert_select "input[type='hidden'][name='page[blocks_attributes][0][identifier]'][value='snippet']"
  end

  def test_get_new_with_page_rich_text
    comfy_cms_layouts(:default).update_columns(:content => '{{cms:page:test_label:rich_text}}')
    get :new, :site_id => @site
    assert_response :success
    assert_select "textarea[name='page[blocks_attributes][0][content]'][data-cms-rich-text]"
    assert_select "input[type='hidden'][name='page[blocks_attributes][0][identifier]'][value='test_label']"
  end

  def test_get_new_with_page_markdown
    comfy_cms_layouts(:default).update_columns(:content => '{{cms:page:test_label:markdown}}')
    get :new, :site_id => @site
    assert_response :success
    assert_select "textarea[name='page[blocks_attributes][0][content]'][data-cms-cm-mode='text/x-markdown']"
    assert_select "input[type='hidden'][name='page[blocks_attributes][0][identifier]'][value='test_label']"
  end

  def test_get_new_with_boolean_field
    comfy_cms_layouts(:default).update_columns(:content => '{{cms:field:test_label:boolean}}')
    get :new, :site_id => @site
    assert_response :success
    assert_select "input[type='hidden'][name='page[blocks_attributes][0][identifier]'][value='test_label']"
    assert_select "input[type='hidden'][name='page[blocks_attributes][0][content]'][value='']"
    assert_select "input[type='checkbox'][name='page[blocks_attributes][0][content]'][value='1']"
  end

  def test_get_new_with_several_tag_fields
    comfy_cms_layouts(:default).update_columns(:content => '{{cms:page:label_a}}{{cms:page:label_b}}')
    get :new, :site_id => @site
    assert_response :success
    assert_select "textarea[name='page[blocks_attributes][0][content]']"
    assert_select "input[type='hidden'][name='page[blocks_attributes][0][identifier]'][value='label_a']"
    assert_select "textarea[name='page[blocks_attributes][1][content]']"
    assert_select "input[type='hidden'][name='page[blocks_attributes][1][identifier]'][value='label_b']"
  end

  def test_get_new_with_crashy_tag
    comfy_cms_layouts(:default).update_columns(:content => '{{cms:collection:label:invalid}}')
    assert_exception_raised do
      get :new, :site_id => @site
    end

    Rails.stubs(:env => ActiveSupport::StringInquirer.new('production'))
    get :new, :site_id => @site
    assert_response :success
  end

  def test_get_new_with_repeated_tag
    comfy_cms_layouts(:default).update_columns(:content => '{{cms:page:test_label}}{{cms:page:test_label}}')
    get :new, :site_id => @site
    assert_response :success
    assert_select "textarea[name='page[blocks_attributes][0][content]']"
    assert_select "input[type='hidden'][name='page[blocks_attributes][0][identifier]'][value='test_label']"
    assert_select "textarea[name='page[blocks_attributes][1][content]']", 0
    assert_select "input[type='hidden'][name='page[blocks_attributes][1][identifier]'][value='test_label']", 0
  end

  def test_get_new_as_child_page
    get :new, :site_id => @site, :parent_id => comfy_cms_pages(:default)
    assert_response :success
    assert assigns(:page)
    assert_equal comfy_cms_pages(:default), assigns(:page).parent
    assert_template :new
  end

  def test_get_edit
    page = comfy_cms_pages(:default)
    get :edit, :site_id => page.site, :id => page
    assert_response :success
    assert assigns(:page)
    assert_template :edit
    assert_select "form[action='/admin/sites/#{page.site.id}/pages/#{page.id}']"
    assert_select "select[data-url='/admin/sites/#{page.site.id}/pages/#{page.id}/form_blocks']"
  end

  def test_get_edit_failure
    get :edit, :site_id => @site, :id => 'not_found'
    assert_response :redirect
    assert_redirected_to :action => :index
    assert_equal 'Page not found', flash[:danger]
  end

  def test_get_edit_with_blank_layout
    page = comfy_cms_pages(:default)
    page.update_columns(:layout_id => nil)
    get :edit, :site_id => page.site, :id => page
    assert_response :success
    assert assigns(:page)
    assert assigns(:page).layout
  end

  def test_get_edit_with_non_english_locale
    site = @site
    site.update_columns(:locale => 'es')
    get :edit, :site_id => site, :id => comfy_cms_pages(:default)
    assert_response :success
  end

  def test_get_edit_with_layout_and_no_tags
    page = comfy_cms_pages(:default)
    page.layout.update_column(:content, '')
    get :edit, :site_id => page.site, :id => page
    assert_response :success
  end

  def test_creation
    assert_difference 'Comfy::Cms::Page.count' do
      assert_difference 'Comfy::Cms::Block.count', 2 do
        post :create, :site_id => @site, :page => {
          :label          => 'Test Page',
          :slug           => 'test-page',
          :parent_id      => comfy_cms_pages(:default).id,
          :layout_id      => comfy_cms_layouts(:default).id,
          :blocks_attributes => [
            { :identifier => 'default_page_text',
              :content    => 'content content' },
            { :identifier => 'default_field_text',
              :content    => 'title content' }
          ]
        }, :commit => 'Create Page'
        assert_response :redirect
        page = Comfy::Cms::Page.last
        assert_equal @site, page.site
        assert_redirected_to :action => :edit, :id => page
        assert_equal 'Page created', flash[:success]
      end
    end
  end

  def test_creation_failure
    assert_no_difference ['Comfy::Cms::Page.count', 'Comfy::Cms::Block.count'] do
      post :create, :site_id => @site, :page => {
        :layout_id => comfy_cms_layouts(:default).id,
        :blocks_attributes => [
          { :identifier => 'default_page_text',
            :content    => 'content content' },
          { :identifier => 'default_field_text',
            :content    => 'title content' }
        ]
      }
      assert_response :success
      page = assigns(:page)
      assert_equal 2, page.blocks.size
      assert_equal ['content content', 'title content'], page.blocks.collect{|b| b.content}
      assert_template :new
      assert_equal 'Failed to create page', flash[:danger]
    end
  end

  def test_update
    page = comfy_cms_pages(:default)
    assert_no_difference 'Comfy::Cms::Block.count' do
      put :update, :site_id => page.site, :id => page, :page => {
        :label => 'Updated Label'
      }
      page.reload
      assert_response :redirect
      assert_redirected_to :action => :edit, :id => page
      assert_equal 'Page updated', flash[:success]
      assert_equal 'Updated Label', page.label
    end
  end

  def test_update_with_layout_change
    page = comfy_cms_pages(:default)
    assert_difference 'Comfy::Cms::Block.count', 2 do
      put :update, :site_id => page.site, :id => page, :page => {
        :label      => 'Updated Label',
        :layout_id  => comfy_cms_layouts(:nested).id,
        :blocks_attributes => [
          { :identifier => 'content',
            :content    => 'new_page_text_content' },
          { :identifier => 'header',
            :content    => 'new_page_string_content' }
        ]
      }
      page.reload
      assert_response :redirect
      assert_redirected_to :action => :edit, :id => page
      assert_equal 'Page updated', flash[:success]
      assert_equal 'Updated Label', page.label
      identifiers = page.blocks.collect {|b| b.identifier}
      assert_equal ['content', 'default_field_text', 'default_page_text', 'header'], identifiers.sort
    end
  end

  def test_update_failure
    put :update, :site_id => @site, :id => comfy_cms_pages(:default), :page => {
      :label => ''
    }
    assert_response :success
    assert_template :edit
    assert assigns(:page)
    assert_equal 'Failed to update page', flash[:danger]
  end

  def test_destroy
    assert_difference 'Comfy::Cms::Page.count', -2 do
      assert_difference 'Comfy::Cms::Block.count', -3 do
        delete :destroy, :site_id => comfy_cms_sites(:default), :id => comfy_cms_pages(:default)
        assert_response :redirect
        assert_redirected_to :action => :index
        assert_equal 'Page deleted', flash[:success]
      end
    end
  end

  def test_get_form_blocks
    site = @site
    xhr :get, :form_blocks, :site_id => site, :id => comfy_cms_pages(:default), :layout_id => comfy_cms_layouts(:nested).id
    assert_response :success
    assert assigns(:page)
    assert_equal 2, assigns(:page).tags.size
    assert_template :form_blocks

    xhr :get, :form_blocks, :site_id => site, :id => comfy_cms_pages(:default), :layout_id => comfy_cms_layouts(:default).id
    assert_response :success
    assert assigns(:page)
    assert_equal 4, assigns(:page).tags.size
    assert_template :form_blocks
  end

  def test_get_form_blocks_for_new_page
    xhr :get, :form_blocks, :site_id => @site, :id => 0, :layout_id => comfy_cms_layouts(:default).id
    assert_response :success
    assert assigns(:page)
    assert_equal 3, assigns(:page).tags.size
    assert_template :form_blocks
  end

  def test_creation_preview
    site    = @site
    layout  = comfy_cms_layouts(:default)

    assert_no_difference 'Comfy::Cms::Page.count' do
      post :create, :site_id => site, :preview => 'Preview', :page => {
        :label      => 'Test Page',
        :slug       => 'test-page',
        :parent_id  => comfy_cms_pages(:default).id,
        :layout_id  => layout.id,
        :blocks_attributes => [
          { :identifier => 'default_page_text',
            :content    => 'preview content' }
        ]
      }
      assert_response :success
      assert_match /preview content/, response.body
      assert_equal 'text/html', response.content_type

      assert_equal site, assigns(:cms_site)
      assert_equal layout, assigns(:cms_layout)
      assert assigns(:cms_page)
      assert assigns(:cms_page).new_record?
    end
  end

  def test_update_preview
    page = comfy_cms_pages(:default)
    assert_no_difference 'Comfy::Cms::Page.count' do
      put :update, :site_id => page.site, :preview => 'Preview', :id => page, :page => {
        :label => 'Updated Label',
        :blocks_attributes => [
          { :identifier => 'default_page_text',
            :content    => 'preview content' }
        ]
      }
      assert_response :success
      assert_match /preview content/, response.body
      page.reload
      assert_not_equal 'Updated Label', page.label

      assert_equal page.site,   assigns(:cms_site)
      assert_equal page.layout, assigns(:cms_layout)
      assert_equal page,        assigns(:cms_page)
    end
  end

  def test_get_new_with_no_layout
    Comfy::Cms::Layout.destroy_all
    get :new, :site_id => @site
    assert_response :redirect
    assert_redirected_to new_comfy_admin_cms_site_layout_path(@site)
    assert_equal 'No Layouts found. Please create one.', flash[:danger]
  end

  def test_get_edit_with_no_layout
    Comfy::Cms::Layout.destroy_all
    page = comfy_cms_pages(:default)
    get :edit, :site_id => page.site, :id => page
    assert_response :redirect
    assert_redirected_to new_comfy_admin_cms_site_layout_path(page.site)
    assert_equal 'No Layouts found. Please create one.', flash[:danger]
  end

  def test_get_toggle_branch
    page = comfy_cms_pages(:default)
    xhr :get, :toggle_branch, :site_id => page.site, :id => page, :format => :js
    assert_response :success
    assert_equal [page.id.to_s], session[:cms_page_tree]

    xhr :get, :toggle_branch, :site_id => page.site, :id => page, :format => :js
    assert_response :success
    assert_equal [], session[:cms_page_tree]
  end

  def test_reorder
    page_one = comfy_cms_pages(:child)
    page_two = @site.pages.create!(
      :parent => comfy_cms_pages(:default),
      :layout => comfy_cms_layouts(:default),
      :label  => 'test',
      :slug   => 'test'
    )
    assert_equal 0, page_one.position
    assert_equal 1, page_two.position

    put :reorder, :site_id => @site, :comfy_cms_page => [page_two.id, page_one.id]
    assert_response :success
    page_one.reload
    page_two.reload

    assert_equal 1, page_one.position
    assert_equal 0, page_two.position
  end
end
