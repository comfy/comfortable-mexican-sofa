# frozen_string_literal: true

require_relative "../../../../test_helper"

class Comfy::Admin::Cms::PagesControllerTest < ActionDispatch::IntegrationTest

  def setup
    @site   = comfy_cms_sites(:default)
    @layout = comfy_cms_layouts(:default)
    @page   = comfy_cms_pages(:default)
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
      label:            "Test Category",
      categorized_type: "Comfy::Cms::Page"
    )
    category.categorizations.create!(categorized: comfy_cms_pages(:child))

    r :get, comfy_admin_cms_site_pages_path(site_id: @site), params: { categories: category.label }
    assert_response :success
    assert assigns(:pages)
    assert_equal 1, assigns(:pages).count
    assert assigns(:pages).first.categories.member? category
  end

  def test_get_index_with_category_invalid
    r :get, comfy_admin_cms_site_pages_path(site_id: @site), params: { categories: "invalid" }
    assert_response :success
    assert assigns(:pages)
    assert_equal 0, assigns(:pages).count
  end

  def test_get_index_with_toggle
    @site.pages.create!(
      label:  "test",
      slug:   "test",
      parent: comfy_cms_pages(:child),
      layout: comfy_cms_layouts(:default)
    )
    r :get, comfy_admin_cms_site_pages_path(site_id: @site)
    assert_response :success
  end

  def test_get_links_with_redactor
    r :get, comfy_admin_cms_site_pages_path(site_id: @site), params: { source: "redactor" }
    assert_response :success

    assert_equal [
      { "name" => "Select page...",  "url" => false },
      { "name" => "Default Page",    "url" => "/" },
      { "name" => ". . Child Page",  "url" => "/child-page" }
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

    assert_select "textarea[name='page[fragments_attributes][0][content]']"
    assert_select "input[type='hidden'][name='page[fragments_attributes][0][identifier]'][value='content']"
    assert_select "input[type='hidden'][name='page[fragments_attributes][0][tag]'][value='text_area']"
  end

  def test_get_new_with_several_fields
    @layout.update_column(:content, "{{cms:wysiwyg a}}{{cms:markdown b}}")
    r :get, new_comfy_admin_cms_site_page_path(site_id: @site)
    assert_response :success
    assert_select "textarea[name='page[fragments_attributes][0][content]']"
    assert_select "input[type='hidden'][name='page[fragments_attributes][0][identifier]'][value='a']"
    assert_select "input[type='hidden'][name='page[fragments_attributes][0][tag]'][value='wysiwyg']"
    assert_select "textarea[name='page[fragments_attributes][1][content]']"
    assert_select "input[type='hidden'][name='page[fragments_attributes][1][identifier]'][value='b']"
    assert_select "input[type='hidden'][name='page[fragments_attributes][1][tag]'][value='markdown']"
  end

  def test_get_new_with_non_renderable_fragment
    @layout.update_column(:content, "{{cms:text a}}{{cms:text b, render: false}}")
    r :get, new_comfy_admin_cms_site_page_path(site_id: @site)
    assert_response :success
    assert_select "label.renderable-true", "A"
    assert_select "label.renderable-false", "B"
  end

  def test_get_new_with_invalid_tag
    @layout.update_column(:content, "{{cms:invalid}}")
    r :get, new_comfy_admin_cms_site_page_path(site_id: @site)
    assert_response :success
    assert_select "div.alert-danger", "Unrecognized tag: {{cms:invalid}}"
  end

  def test_get_new_with_invalid_fragment_tag
    @layout.update_column(:content, "a {{cms:markdown}} b")
    r :get, new_comfy_admin_cms_site_page_path(site_id: @site)
    assert_response :success
    assert_select "div.alert-danger", "Missing identifier for fragment tag: {{cms:markdown}}"
  end

  def test_get_new_with_repeated_tag
    @layout.update_column(:content, "{{cms:text test}}{{cms:text test}}")
    r :get, new_comfy_admin_cms_site_page_path(site_id: @site)
    assert_response :success
    assert_select "input[name='page[fragments_attributes][0][content]']"
    assert_select "input[type='hidden'][name='page[fragments_attributes][0][identifier]'][value='test']"
    assert_select "input[name='page[fragments_attributes][1][content]']", 0
    assert_select "input[type='hidden'][name='page[fragments_attributes][1][identifier]'][value='test']", 0
  end

  def test_get_new_with_namespaced_tags
    @layout.update_column(:content, "{{cms:text a, namespace: a}}{{cms:text b, namespace: b}}")
    r :get, new_comfy_admin_cms_site_page_path(site_id: @site)
    assert_response :success
    assert_select "a[data-toggle='tab'][href='#ns-a']", "A"
    assert_select "a[data-toggle='tab'][href='#ns-b']", "B"
    assert_select "input[name='page[fragments_attributes][0][content]']"
    assert_select "input[type='hidden'][name='page[fragments_attributes][0][identifier]'][value='a']"
    assert_select "input[name='page[fragments_attributes][1][content]']"
    assert_select "input[type='hidden'][name='page[fragments_attributes][1][identifier]'][value='b']"
  end

  def test_get_new_with_localized_names
    I18n.backend.store_translations(:en, comfy: { cms: { content:
      { tag:        { localized_a: "Localized Fragment" },
        namespace:  { localized_a: "Localized Namespace" } }
    } })
    @layout.update_column(
      :content,
      "{{cms:text localized_a, namespace: localized_a}}{{cms:text b, namespace: b}}"
    )
    r :get, new_comfy_admin_cms_site_page_path(site_id: @site)
    assert_response :success

    assert_select "a[data-toggle='tab'][href='#ns-localized_a']", "Localized Namespace"
    assert_select "label", "Localized Fragment"
  ensure
    I18n.backend.store_translations(:en, comfy: { cms: { content:
      { tag: nil, namespace: nil }
    } })
  end

  def test_get_new_as_child_page
    r :get, new_comfy_admin_cms_site_page_path(site_id: @site), params: { parent_id: @page }
    assert_response :success
    assert assigns(:page)
    assert_equal comfy_cms_pages(:default), assigns(:page).parent
    assert_template :new
  end

  def test_get_edit
    r :get, edit_comfy_admin_cms_site_page_path(site_id: @site, id: @page)
    assert_response :success
    assert assigns(:page)
    assert_template :edit
    assert_select "form[action='/admin/sites/#{@site.id}/pages/#{@page.id}']"
    assert_select "select[data-url='/admin/sites/#{@site.id}/pages/#{@page.id}/form_fragments']"
  end

  def test_get_edit_failure
    r :get, edit_comfy_admin_cms_site_page_path(site_id: @site, id: "not_found")
    assert_response :redirect
    assert_redirected_to action: :index
    assert_equal "Page not found", flash[:danger]
  end

  def test_get_edit_with_blank_layout
    @page.update_column(:layout_id, nil)
    r :get, edit_comfy_admin_cms_site_page_path(site_id: @site, id: @page)
    assert_response :success
    assert assigns(:page)
  end

  def test_get_edit_with_non_english_locale
    @site.update_column(:locale, "es")
    r :get, edit_comfy_admin_cms_site_page_path(site_id: @site, id: @page)
    assert_response :success
  end

  def test_get_edit_with_layout_and_no_tags
    @page.layout.update_column(:content, "")
    r :get, edit_comfy_admin_cms_site_page_path(site_id: @site, id: @page)
    assert_response :success
  end

  def test_creation
    assert_difference "Comfy::Cms::Page.count" do
      assert_difference "Comfy::Cms::Fragment.count", 2 do
        r :post, comfy_admin_cms_site_pages_path(site_id: @site), params: {
          page: {
            label:              "Test Page",
            slug:               "test-page",
            parent_id:          @page.id,
            layout_id:          @layout.id,
            fragments_attributes: [
              { identifier: "default_page_text",
                content:    "content content" },
              { identifier: "default_field_text",
                content:    "title content" }
            ]
          },
          commit: "Create Page"
        }
        assert_response :redirect
        page = Comfy::Cms::Page.last
        assert_equal @site, page.site
        assert_redirected_to action: :edit, id: page
        assert_equal "Page created", flash[:success]
      end
    end
  end

  def test_creation_with_files
    assert_difference "Comfy::Cms::Page.count" do
      assert_difference "Comfy::Cms::Fragment.count", 3 do
        assert_difference "ActiveStorage::Attachment.count", 3 do
          r :post, comfy_admin_cms_site_pages_path(site_id: @site), params: {
            page: {
              label:     "Test Page",
              slug:      "test-page",
              parent_id: @page.id,
              layout_id: @layout.id,
              fragments_attributes: [
                { identifier: "image",
                  tag:        "file",
                  files:      fixture_file_upload("files/image.jpg", "image/jpeg")
                },
                { identifier: "files_multiple",
                  tag:        "files",
                  files: [
                    fixture_file_upload("files/image.jpg", "image/jpeg"),
                    fixture_file_upload("files/document.pdf", "application/pdf")
                  ]
                },
                { identifier: "unpopulated",
                  tag:        "file",
                  content:    nil
                }
              ]
            },
            commit: "Create Page"
          }
          assert_response :redirect
          page = Comfy::Cms::Page.last
          assert_equal @site, page.site
          assert_redirected_to action: :edit, id: page
          assert_equal "Page created", flash[:success]
        end
      end
    end
  end

  def test_creation_failure
    assert_no_difference ["Comfy::Cms::Page.count", "Comfy::Cms::Fragment.count"] do
      r :post, comfy_admin_cms_site_pages_path(site_id: @site), params: { page: {
        layout_id: @layout.id,
        fragments_attributes: [
          { identifier: "content",
            content:    "content content" },
          { identifier: "title",
            content:    "title content" }
        ]
      } }
      assert_response :success
      page = assigns(:page)

      assert_equal 2, page.fragments.size
      assert_equal ["content content", "title content"], page.fragments.collect(&:content)
      assert_template :new
      assert_equal "Failed to create page", flash[:danger]
    end
  end

  def test_update
    assert_no_difference "Comfy::Cms::Fragment.count" do
      r :put, comfy_admin_cms_site_page_path(site_id: @site, id: @page), params: { page: {
        label: "Updated Label"
      } }
      @page.reload
      assert_response :redirect
      assert_redirected_to action: :edit, id: @page
      assert_equal "Page updated", flash[:success]
      assert_equal "Updated Label", @page.label
    end
  end

  def test_update_with_layout_change
    assert_difference "Comfy::Cms::Fragment.count" do
      r :put, comfy_admin_cms_site_page_path(site_id: @site, id: @page), params: { page: {
        label:      "Updated Label",
        layout_id:  comfy_cms_layouts(:nested).id,
        fragments_attributes: [
          { identifier: "content",
            content:    "new_page_text_content" },
          { identifier: "header",
            content:    "new_page_string_content" }
        ]
      } }
      @page.reload
      assert_response :redirect
      assert_redirected_to action: :edit, id: @page
      assert_equal "Page updated", flash[:success]
      assert_equal "Updated Label", @page.label
      identifiers = @page.fragments.collect(&:identifier)
      assert_equal %w[boolean content datetime file header], identifiers.sort
    end
  end

  def test_update_failure
    r :put, comfy_admin_cms_site_page_path(site_id: @site, id: @page), params: { page: {
      label: ""
    } }
    assert_response :success
    assert_template :edit
    assert assigns(:page)
    assert_equal "Failed to update page", flash[:danger]
  end

  def test_destroy
    assert_difference "Comfy::Cms::Page.count", -2 do
      assert_difference "Comfy::Cms::Fragment.count", -5 do
        r :delete, comfy_admin_cms_site_page_path(site_id: @site, id: @page)
        assert_response :redirect
        assert_redirected_to action: :index
        assert_equal "Page deleted", flash[:success]
      end
    end
  end

  def test_get_form_fragments
    r :get, form_fragments_comfy_admin_cms_site_page_path(site_id: @site, id: @page), xhr: true, params: {
      layout_id: comfy_cms_layouts(:nested).id
    }
    assert_response :success
    assert assigns(:page)
    assert_equal 2, assigns(:page).fragment_nodes.size
    assert_template "comfy/admin/cms/fragments/_form_fragments"

    r :get, form_fragments_comfy_admin_cms_site_page_path(site_id: @site, id: @page), xhr: true, params: {
      layout_id: @layout.id
    }
    assert_response :success
    assert assigns(:page)
    assert_equal 1, assigns(:page).fragment_nodes.size
    assert_template "comfy/admin/cms/fragments/_form_fragments"
  end

  def test_get_form_fragments_for_new_page
    r :get, form_fragments_comfy_admin_cms_site_page_path(site_id: @site, id: 0), xhr: true, params: {
      layout_id: @layout.id
    }
    assert_response :success
    assert assigns(:page)
    assert_equal 1, assigns(:page).fragment_nodes.size
    assert_template "comfy/admin/cms/fragments/_form_fragments"
  end

  def test_creation_preview
    assert_no_difference "Comfy::Cms::Page.count" do
      r :post, comfy_admin_cms_site_pages_path(site_id: @site), params: {
        preview: "Preview",
        page: {
          label:     "Test Page",
          slug:      "test-page",
          parent_id: @page.id,
          layout_id: @layout.id,
          fragments_attributes: [
            { identifier: "content",
              content:    "preview content" }
          ]
        }
      }
      assert_response :success
      assert_match %r{preview content}, response.body
      assert_equal "text/html", response.content_type

      assert_equal @site, assigns(:cms_site)
      assert_equal @layout, assigns(:cms_layout)
      assert assigns(:cms_page)
      assert assigns(:cms_page).new_record?
    end
  end

  def test_update_preview
    assert_no_difference "Comfy::Cms::Page.count" do
      r :put, comfy_admin_cms_site_page_path(site_id: @site, id: @page), params: {
        preview: "Preview",
        page: {
          label: "Updated Label",
          fragments_attributes: [
            { identifier: "content",
              content:    "preview content" }
          ]
        }
      }
      assert_response :success
      assert_match %r{preview content}, response.body
      @page.reload
      assert_not_equal "Updated Label", @page.label

      assert_equal @page.site,   assigns(:cms_site)
      assert_equal @page.layout, assigns(:cms_layout)
      assert_equal @page,        assigns(:cms_page)
    end
  end

  def test_preview_language
    @site.update_column(:locale, "de")

    assert_equal :en, I18n.locale

    r :post, comfy_admin_cms_site_pages_path(site_id: @site), params: {
      preview: "Preview",
      page: {
        label:     "Test Page",
        slug:      "test-page",
        parent_id: @page.id,
        layout_id: @layout.id,
        fragments_attributes: [
          { identifier: "content",
            content:    "preview content" }
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
    assert_equal "No Layouts found. Please create one.", flash[:danger]
  end

  def test_get_edit_with_no_layout
    Comfy::Cms::Layout.destroy_all
    r :get, edit_comfy_admin_cms_site_page_path(site_id: @site, id: @page)
    assert_response :redirect
    assert_redirected_to new_comfy_admin_cms_site_layout_path(@site)
    assert_equal "No Layouts found. Please create one.", flash[:danger]
  end

  def test_get_toggle_branch
    r :get, toggle_branch_comfy_admin_cms_site_page_path(site_id: @site, id: @page), xhr: true, params: { format: :js }
    assert_response :success
    assert_equal [@page.id.to_s], session[:cms_page_tree]

    r :get, toggle_branch_comfy_admin_cms_site_page_path(site_id: @site, id: @page), xhr: true, params: { format: :js }
    assert_response :success
    assert_equal [], session[:cms_page_tree]
  end

  def test_reorder
    page_one = comfy_cms_pages(:child)
    page_two = @site.pages.create!(
      parent: @page,
      layout: @layout,
      label:  "test",
      slug:   "test"
    )
    assert_equal 0, page_one.position
    assert_equal 1, page_two.position

    r :put, reorder_comfy_admin_cms_site_pages_path(site_id: @site), params: {
      order: [page_two.id, page_one.id]
    }
    assert_response :success
    page_one.reload
    page_two.reload

    assert_equal 1, page_one.position
    assert_equal 0, page_two.position
  end

end
