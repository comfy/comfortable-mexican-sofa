require_relative '../../../../test_helper'

class Comfy::Admin::Cms::PagesControllerTest < ActionDispatch::IntegrationTest

  def setup
    @site   = comfy_cms_sites(:default)
    @layout = comfy_cms_layouts(:default)
  end

  def test_get_index
    r :get, comfy_admin_cms_site_pages_path(site_id: @site)
    assert_response :success
    assert assigns(:pages)
    assert_template :index
  end

  def test_get_index_with_no_pages
    Comfy::Cms::Page.delete_all
    r :get, comfy_admin_cms_site_pages_path(site_id: @site)
    assert_response :redirect
    assert_redirected_to action: :new
  end

  def test_get_index_with_category
    category = @site.categories.create!(
      label:            'Test Category',
      categorized_type: 'Comfy::Cms::Page'
    )
    category.categorizations.create!(categorized: comfy_cms_pages(:child))

    r :get, comfy_admin_cms_site_pages_path(site_id: @site), params: {category: category.label}
    assert_response :success
    assert assigns(:pages)
    assert_equal 1, assigns(:pages).count
    assert assigns(:pages).first.categories.member? category
  end

  def test_get_index_with_category_invalid
    r :get, comfy_admin_cms_site_pages_path(site_id: @site), params: {category: 'invalid'}
    assert_response :success
    assert assigns(:pages)
    assert_equal 0, assigns(:pages).count
  end

  def test_get_index_with_toggle
    @site.pages.create!(
      label:  'test',
      slug:   'test',
      parent: comfy_cms_pages(:child),
      layout: comfy_cms_layouts(:default)
    )
    r :get, comfy_admin_cms_site_pages_path(site_id: @site)
    assert_response :success
  end

  def test_get_links_with_redactor
    r :get, comfy_admin_cms_site_pages_path(site_id: @site), params: {source: 'redactor'}
    assert_response :success

    assert_equal [
      {'name' => 'Select page...',  'url' => false},
      {'name' => 'Default Page',    'url' => '/'},
      {'name' => '. . Child Page',  'url' => '/child-page'}
    ], JSON.parse(response.body)
  end

  def test_get_new
    r :get, new_comfy_admin_cms_site_page_path(site_id: @site)
    assert_response :success
    assert assigns(:page)
    assert_equal @layout, assigns(:page).layout
    assert_template :new
    assert_select "form[action='/admin/sites/#{@site.id}/pages']"
    assert_select "select[data-url='/admin/sites/#{@site.id}/pages/0/form_fragments']"
  end

  def test_get_new_with_field_wysiwyg
    @layout.update_column(:content, "{{cms:fragment test, format: wysiwyg}}")
    r :get, new_comfy_admin_cms_site_page_path(site_id: @site)
    assert_response :success
    assert_select "textarea[name='page[fragments_attributes][0][content]'][data-cms-rich-text]"
    assert_select "input[type='hidden'][name='page[fragments_attributes][0][identifier]'][value='test']"
    assert_select "input[type='hidden'][name='page[fragments_attributes][0][format]'][value='wysiwyg']"
  end

  def test_get_new_with_field_text
    @layout.update_column(:content, "{{cms:fragment test, format: text}}")
    r :get, new_comfy_admin_cms_site_page_path(site_id: @site)
    assert_response :success
    assert_select "input[type='text'][name='page[fragments_attributes][0][content]']"
    assert_select "input[type='hidden'][name='page[fragments_attributes][0][identifier]'][value='test']"
    assert_select "input[type='hidden'][name='page[fragments_attributes][0][format]'][value='text']"
  end

  def test_get_new_with_field_textarea
    @layout.update_column(:content, "{{cms:fragment test, format: textarea}}")
    r :get, new_comfy_admin_cms_site_page_path(site_id: @site)
    assert_response :success
    assert_select "textarea[name='page[fragments_attributes][0][content]'][data-cms-cm-mode='text/html']"
    assert_select "input[type='hidden'][name='page[fragments_attributes][0][identifier]'][value='test']"
    assert_select "input[type='hidden'][name='page[fragments_attributes][0][format]'][value='textarea']"
  end

  def test_get_new_with_field_markdown
    @layout.update_column(:content, "{{cms:fragment test, format: markdown}}")
    r :get, new_comfy_admin_cms_site_page_path(site_id: @site)
    assert_response :success
    assert_select "textarea[name='page[fragments_attributes][0][content]'][data-cms-cm-mode='text/x-markdown']"
    assert_select "input[type='hidden'][name='page[fragments_attributes][0][identifier]'][value='test']"
    assert_select "input[type='hidden'][name='page[fragments_attributes][0][format]'][value='markdown']"
  end

  def test_get_new_with_field_datetime
    @layout.update_column(:content, "{{cms:fragment test, format: datetime}}")
    r :get, new_comfy_admin_cms_site_page_path(site_id: @site)
    assert_response :success
    assert_select "input[type='text'][name='page[fragments_attributes][0][content]'][data-cms-datetime]"
    assert_select "input[type='hidden'][name='page[fragments_attributes][0][identifier]'][value='test']"
    assert_select "input[type='hidden'][name='page[fragments_attributes][0][format]'][value='datetime']"
  end

  def test_get_new_with_field_date
    @layout.update_column(:content, "{{cms:fragment test, format: date}}")
    r :get, new_comfy_admin_cms_site_page_path(site_id: @site)
    assert_response :success
    assert_select "input[type='text'][name='page[fragments_attributes][0][content]'][data-cms-date]"
    assert_select "input[type='hidden'][name='page[fragments_attributes][0][identifier]'][value='test']"
    assert_select "input[type='hidden'][name='page[fragments_attributes][0][format]'][value='date']"
  end

  def test_get_new_with_field_number
    @layout.update_column(:content, "{{cms:fragment test, format: number}}")
    r :get, new_comfy_admin_cms_site_page_path(site_id: @site)
    assert_response :success
    assert_select "input[type='number'][name='page[fragments_attributes][0][content]']"
    assert_select "input[type='hidden'][name='page[fragments_attributes][0][identifier]'][value='test']"
    assert_select "input[type='hidden'][name='page[fragments_attributes][0][format]'][value='number']"
  end

  def test_get_new_with_field_checkbox
    @layout.update_column(:content, "{{cms:fragment test, format: checkbox}}")
    r :get, new_comfy_admin_cms_site_page_path(site_id: @site)
    assert_response :success
    assert_select "input[type='hidden'][name='page[fragments_attributes][0][content]'][value='']"
    assert_select "input[type='checkbox'][name='page[fragments_attributes][0][content]'][value='1']"
    assert_select "input[type='hidden'][name='page[fragments_attributes][0][identifier]'][value='test']"
    assert_select "input[type='hidden'][name='page[fragments_attributes][0][format]'][value='checkbox']"
  end

  def test_get_new_with_field_file
    @layout.update_column(:content, "{{cms:file test}}")
    r :get, new_comfy_admin_cms_site_page_path(site_id: @site)
    assert_response :success
    assert_select "input[type='file'][name='page[fragments_attributes][0][content]']"
    assert_select "input[type='hidden'][name='page[fragments_attributes][0][identifier]'][value='test']"
    assert_select "input[type='hidden'][name='page[fragments_attributes][0][format]'][value='file']"
  end

  def test_get_new_with_field_file_multiple
    @layout.update_column(:content, "{{cms:file test, multiple: true}}")
    r :get, new_comfy_admin_cms_site_page_path(site_id: @site)
    assert_response :success
    assert_select "input[type='file'][name='page[fragments_attributes][0][content][]'][multiple=multiple]"
    assert_select "input[type='hidden'][name='page[fragments_attributes][0][identifier]'][value='test']"
    assert_select "input[type='hidden'][name='page[fragments_attributes][0][format]'][value='file']"
  end

  def test_get_new_with_several_fields
    @layout.update_column(:content, "{{cms:fragment a}}{{cms:fragment b}}")
    r :get, new_comfy_admin_cms_site_page_path(site_id: @site)
    assert_response :success
    assert_select "textarea[name='page[fragments_attributes][0][content]']"
    assert_select "input[type='hidden'][name='page[fragments_attributes][0][identifier]'][value='a']"
    assert_select "input[type='hidden'][name='page[fragments_attributes][0][format]'][value='wysiwyg']"
    assert_select "textarea[name='page[fragments_attributes][1][content]']"
    assert_select "input[type='hidden'][name='page[fragments_attributes][1][identifier]'][value='b']"
    assert_select "input[type='hidden'][name='page[fragments_attributes][1][format]'][value='wysiwyg']"
  end

  def test_get_new_with_crashy_tag
    @layout.update_column(:content, "{{cms:fragment}}")
    assert_exception_raised do
      r :get, new_comfy_admin_cms_site_page_path(site_id: @site)
    end

    Rails.stubs(env: ActiveSupport::StringInquirer.new("production"))
    r :get, new_comfy_admin_cms_site_page_path(site_id: @site)
    assert_response :success
  end

  def test_get_new_with_repeated_tag
    @layout.update_column(:content, "{{cms:fragment test}}{{cms:fragment test}}")
    r :get, new_comfy_admin_cms_site_page_path(site_id: @site)
    assert_response :success
    assert_select "textarea[name='page[fragments_attributes][0][content]']"
    assert_select "input[type='hidden'][name='page[fragments_attributes][0][identifier]'][value='test']"
    assert_select "textarea[name='page[fragments_attributes][1][content]']", 0
    assert_select "input[type='hidden'][name='page[fragments_attributes][1][identifier]'][value='test']", 0
  end





  def test_get_new_as_child_page
    r :get, new_comfy_admin_cms_site_page_path(site_id: @site), params: {parent_id: comfy_cms_pages(:default)}
    assert_response :success
    assert assigns(:page)
    assert_equal comfy_cms_pages(:default), assigns(:page).parent
    assert_template :new
  end

  def test_get_edit
    page = comfy_cms_pages(:default)
    r :get, edit_comfy_admin_cms_site_page_path(site_id: @site, id: page)
    assert_response :success
    assert assigns(:page)
    assert_template :edit
    assert_select "form[action='/admin/sites/#{page.site.id}/pages/#{page.id}']"
    assert_select "select[data-url='/admin/sites/#{page.site.id}/pages/#{page.id}/form_blocks']"
  end

  def test_get_edit_failure
    r :get, edit_comfy_admin_cms_site_page_path(site_id: @site, id: 'not_found')
    assert_response :redirect
    assert_redirected_to action: :index
    assert_equal 'Page not found', flash[:danger]
  end

  def test_get_edit_with_blank_layout
    page = comfy_cms_pages(:default)
    page.update_columns(layout_id: nil)
    r :get, edit_comfy_admin_cms_site_page_path(site_id: @site, id: page)
    assert_response :success
    assert assigns(:page)
    assert assigns(:page).layout
  end

  def test_get_edit_with_non_english_locale
    @site.update_columns(:locale => 'es')
    r :get, edit_comfy_admin_cms_site_page_path(site_id: @site, id: comfy_cms_pages(:default))
    assert_response :success
  end

  def test_get_edit_with_layout_and_no_tags
    page = comfy_cms_pages(:default)
    page.layout.update_column(:content, '')
    r :get, edit_comfy_admin_cms_site_page_path(site_id: @site, id: page)
    assert_response :success
  end

  def test_creation
    assert_difference 'Comfy::Cms::Page.count' do
      assert_difference 'Comfy::Cms::Block.count', 2 do
        r :post, comfy_admin_cms_site_pages_path(site_id: @site), params: {
          page: {
            label:              'Test Page',
            slug:               'test-page',
            parent_id:          comfy_cms_pages(:default).id,
            layout_id:          (:default).id,
            blocks_attributes: [
              { identifier: 'default_page_text',
                content:    'content content' },
              { identifier: 'default_field_text',
                content:    'title content' }
            ]
          },
          commit: 'Create Page'
        }
        assert_response :redirect
        page = Comfy::Cms::Page.last
        assert_equal @site, page.site
        assert_redirected_to action: :edit, id: page
        assert_equal 'Page created', flash[:success]
      end
    end
  end

  def test_creation_failure
    assert_no_difference ['Comfy::Cms::Page.count', 'Comfy::Cms::Block.count'] do
      r :post, comfy_admin_cms_site_pages_path(site_id: @site), params: {page: {
        layout_id: (:default).id,
        blocks_attributes: [
          { identifier: 'default_page_text',
            content:    'content content' },
          { identifier: 'default_field_text',
            content:    'title content' }
        ]
      }}
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
      r :put, comfy_admin_cms_site_page_path(site_id: @site, id: page), params: {page: {
        label: 'Updated Label'
      }}
      page.reload
      assert_response :redirect
      assert_redirected_to action: :edit, id: page
      assert_equal 'Page updated', flash[:success]
      assert_equal 'Updated Label', page.label
    end
  end

  def test_update_with_layout_change
    page = comfy_cms_pages(:default)
    assert_difference 'Comfy::Cms::Block.count', 2 do
      r :put, comfy_admin_cms_site_page_path(site_id: @site, id: page), params: {page: {
        label:      'Updated Label',
        layout_id:  comfy_cms_layouts(:nested).id,
        blocks_attributes: [
          { identifier: 'content',
            content:    'new_page_text_content' },
          { identifier: 'header',
            content:    'new_page_string_content' }
        ]
      }}
      page.reload
      assert_response :redirect
      assert_redirected_to action: :edit, id: page
      assert_equal 'Page updated', flash[:success]
      assert_equal 'Updated Label', page.label
      identifiers = page.blocks.collect {|b| b.identifier}
      assert_equal ['content', 'default_field_text', 'default_page_text', 'header'], identifiers.sort
    end
  end

  def test_update_failure
    r :put, comfy_admin_cms_site_page_path(site_id: @site, id: comfy_cms_pages(:default)), params: {page: {
      label: ''
    }}
    assert_response :success
    assert_template :edit
    assert assigns(:page)
    assert_equal 'Failed to update page', flash[:danger]
  end

  def test_destroy
    assert_difference 'Comfy::Cms::Page.count', -2 do
      assert_difference 'Comfy::Cms::Block.count', -2 do
        r :delete, comfy_admin_cms_site_page_path(site_id: @site, id: comfy_cms_pages(:default))
        assert_response :redirect
        assert_redirected_to action: :index
        assert_equal 'Page deleted', flash[:success]
      end
    end
  end

  def test_get_form_blocks
    page = comfy_cms_pages(:default)

    r :get, form_blocks_comfy_admin_cms_site_page_path(site_id: @site, id: page), xhr: true, params: {
      layout_id: (:nested).id
    }
    assert_response :success
    assert assigns(:page)
    assert_equal 2, assigns(:page).tags.size
    assert_template :form_blocks

    r :get, form_blocks_comfy_admin_cms_site_page_path(site_id: @site, id: page), xhr: true, params: {
      layout_id: comfy_cms_layouts(:default).id
    }
    assert_response :success
    assert assigns(:page)
    assert_equal 4, assigns(:page).tags.size
    assert_template :form_blocks
  end

  def test_get_form_blocks_for_new_page
    r :get, form_blocks_comfy_admin_cms_site_page_path(site_id: @site, id: 0), xhr: true, params: {
      layout_id: comfy_cms_layouts(:default).id
    }
    assert_response :success
    assert assigns(:page)
    assert_equal 3, assigns(:page).tags.size
    assert_template :form_blocks
  end

  def test_creation_preview
    site    = @site
    layout  = comfy_cms_layouts(:default)

    assert_no_difference 'Comfy::Cms::Page.count' do
      r :post, comfy_admin_cms_site_pages_path(site_id: @site), params: {
        preview: 'Preview',
        page: {
          label:     'Test Page',
          slug:      'test-page',
          parent_id: comfy_cms_pages(:default).id,
          layout_id: layout.id,
          blocks_attributes: [
            { identifier: 'default_page_text',
              content:    'preview content' }
          ]
        }
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
      r :put, comfy_admin_cms_site_page_path(site_id: @site, id: page), params: {
        preview: 'Preview',
        page: {
        label: 'Updated Label',
        blocks_attributes: [
          { identifier: 'default_page_text',
            content:    'preview content' }
          ]
        }
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

  def test_preview_language
    @site.update_columns(locale: 'de')
    layout = comfy_cms_layouts(:default)

    assert_equal :en, I18n.locale

    r :post, comfy_admin_cms_site_pages_path(site_id: @site), params: {
      preview: 'Preview',
      page: {
        label:     'Test Page',
        slug:      'test-page',
        parent_id: comfy_cms_pages(:default).id,
        layout_id: layout.id,
        blocks_attributes: [
          { identifier: 'default_page_text',
            content:    'preview content' }
        ]
      }
    }

    assert_response :success
    assert_equal :de, I18n.locale
  end

  def test_get_new_with_no_layout
    Comfy::Cms::Layout.destroy_all
    r :get, new_comfy_admin_cms_site_page_path(site_id: @site)
    assert_response :redirect
    assert_redirected_to new_comfy_admin_cms_site_layout_path(@site)
    assert_equal 'No Layouts found. Please create one.', flash[:danger]
  end

  def test_get_edit_with_no_layout
    Comfy::Cms::Layout.destroy_all
    page = comfy_cms_pages(:default)
    r :get, edit_comfy_admin_cms_site_page_path(site_id: @site, id: page)
    assert_response :redirect
    assert_redirected_to new_comfy_admin_cms_site_layout_path(page.site)
    assert_equal 'No Layouts found. Please create one.', flash[:danger]
  end

  def test_get_toggle_branch
    page = comfy_cms_pages(:default)
    r :get, toggle_branch_comfy_admin_cms_site_page_path(site_id: @site, id: page), xhr: true, params: {format: :js}
    assert_response :success
    assert_equal [page.id.to_s], session[:cms_page_tree]

    r :get, toggle_branch_comfy_admin_cms_site_page_path(site_id: @site, id: page), xhr: true, params: {format: :js}
    assert_response :success
    assert_equal [], session[:cms_page_tree]
  end

  def test_reorder
    page_one = comfy_cms_pages(:child)
    page_two = @site.pages.create!(
      parent: comfy_cms_pages(:default),
      layout: comfy_cms_layouts(:default),
      label:  'test',
      slug:   'test'
    )
    assert_equal 0, page_one.position
    assert_equal 1, page_two.position

    r :put, reorder_comfy_admin_cms_site_pages_path(site_id: @site), params: {
      comfy_cms_page: [page_two.id, page_one.id]
    }
    assert_response :success
    page_one.reload
    page_two.reload

    assert_equal 1, page_one.position
    assert_equal 0, page_two.position
  end
end
