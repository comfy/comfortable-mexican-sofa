# frozen_string_literal: true

require_relative "../../../test_helper"

class Comfy::Cms::ContentControllerTest < ActionDispatch::IntegrationTest

  setup do
    @site         = comfy_cms_sites(:default)
    @layout       = comfy_cms_layouts(:default)
    @page         = comfy_cms_pages(:default)
    @translation  = comfy_cms_translations(:default)
  end

  def test_show
    get comfy_cms_render_page_path(cms_path: "")
    assert_equal @site,   assigns(:cms_site)
    assert_equal @layout, assigns(:cms_layout)
    assert_equal @page,   assigns(:cms_page)

    assert_response :success
    assert_equal "content", response.body
    assert_equal "text/html", response.content_type

    assert_equal :en, I18n.locale
  end

  def test_show_default_html
    get comfy_cms_render_page_path(cms_path: ""), headers: { "Accept" => "*/*" }
    assert_response :success
    assert_equal "text/html", response.content_type
  end

  def test_show_as_json
    get comfy_cms_render_page_path(cms_path: ""), as: :json
    assert_response :success
    assert_equal "application/json", response.content_type

    json_response = JSON.parse(response.body)
    assert_equal @page.id,        json_response["id"]
    assert_equal @page.site.id,   json_response["site_id"]
    assert_equal @page.layout.id, json_response["layout_id"]
    assert_nil                    json_response["parent_id"]
    assert_nil                    json_response["target_page_id"]
    assert_equal "Default Page",  json_response["label"]
    assert_nil                    json_response["slug"]
    assert_equal "/",             json_response["full_path"]
    assert_equal "content",       json_response["content"]
    assert_equal 0,               json_response["position"]
    assert_equal 1,               json_response["children_count"]
    assert_equal true,            json_response["is_published"]
  end

  def test_show_as_json_with_options
    ComfortableMexicanSofa.config.page_to_json_options = {
      include:  { fragments: { only: :identifier } },
      except:   [:position]
    }

    get comfy_cms_render_page_path(cms_path: ""), as: :json
    assert_response :success
    assert_equal "application/json", response.content_type
    json_response = JSON.parse(response.body)

    # assert_nil json_response["position"]
    assert_equal [
      { "identifier" => "boolean" },
      { "identifier" => "file" },
      { "identifier" => "datetime" },
      { "identifier" => "content" }
    ], json_response["fragments"]
  end

  def test_show_as_json_with_translation
    ComfortableMexicanSofa.config.page_to_json_options = {
      methods: [:content],
      include: { fragments: { only: :content } }
    }

    I18n.locale = :fr

    get comfy_cms_render_page_path(cms_path: ""), as: :json
    assert_response :success
    assert_equal "application/json", response.content_type
    json_response = JSON.parse(response.body)

    assert_equal "Translation Content", json_response["content"]
    assert({ "content" => "translated content" }.in?(json_response["fragments"]))
  end

  def test_show_as_json_with_erb
    @page.update(fragments_attributes: [
      { identifier: "content", content: "{{ cms:helper pluralize, 2, monkey }}" }
    ])
    get comfy_cms_render_page_path(cms_path: ""), as: :json
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_equal "2 monkeys", json_response["content"]
  end

  def test_show_with_custom_mimetype
    layout = @site.layouts.create!(
      label:      "RSS Layout",
      identifier: "rss-layout",
      content:    "{{cms:text mime_type, render: false}}{{cms:textarea content}}"
    )
    @site.pages.create!(
      label:          "rss",
      slug:           "rss",
      parent_id:      comfy_cms_pages(:default).id,
      layout_id:      layout.id,
      is_published:   true,
      fragments_attributes: [
        { identifier: "content",
          content:    "content" },
        { identifier: "mime_type",
          content:    "application/rss+xml" }
      ]
    )
    get comfy_cms_render_page_path(cms_path: "rss")
    assert_response :success
    assert_equal "application/rss+xml", response.content_type
  end

  def test_show_with_app_layout
    @layout.update_columns(app_layout: "comfy/admin/cms")
    get comfy_cms_render_page_path(cms_path: "")
    assert_response :success
    assert assigns(:cms_page)
    assert_select "body.c-comfy-cms-content.a-show"
  end

  def test_show_with_xhr
    @layout.update_columns(app_layout: "cms_admin")
    get comfy_cms_render_page_path(cms_path: ""), xhr: true
    assert_response :success
    assert assigns(:cms_page)
    assert_no_select "body.c-comfy-cms-content.a-show"
  end

  def test_show_not_found
    assert_exception_raised ActionController::RoutingError, 'Page Not Found at: "doesnotexist"' do
      get comfy_cms_render_page_path(cms_path: "doesnotexist")
    end
  end

  def test_show_not_found_with_custom_404
    page = @site.pages.create!(
      label:          "404",
      slug:           "404",
      parent_id:      @page.id,
      layout_id:      @layout.id,
      is_published:   "1",
      fragments_attributes: [
        { identifier: "content",
          content:    "custom 404 page content" }
      ]
    )
    assert_equal "/404", page.full_path
    assert page.is_published?
    get comfy_cms_render_page_path(cms_path: "doesnotexist")
    assert_response :not_found
    assert assigns(:cms_page)
    assert_match %r{custom 404 page content}, response.body
  end

  def test_show_with_no_site
    Comfy::Cms::Site.destroy_all

    assert_exception_raised ActionController::RoutingError, "Site Not Found" do
      get comfy_cms_render_page_path(cms_path: "")
    end
  end

  def test_show_with_no_layout
    Comfy::Cms::Layout.destroy_all

    get comfy_cms_render_page_path(cms_path: "")
    assert_response :ok
    assert_equal "", response.body
  end

  def test_show_with_redirect
    comfy_cms_pages(:child).update_columns(target_page_id: @page.id)
    assert_equal @page, comfy_cms_pages(:child).target_page
    get comfy_cms_render_page_path(cms_path: "child-page")
    assert_response :redirect
    assert_redirected_to @page.full_path
  end

  def test_show_with_redirect_and_site_path
    @site.update_column(:path, "test-site-path")
    comfy_cms_pages(:child).update_columns(target_page_id: @page.id)
    assert_equal @page, comfy_cms_pages(:child).target_page
    get comfy_cms_render_page_path(cms_path: "/test-site-path/child-page")
    assert_response :redirect
    assert_redirected_to "/test-site-path#{@page.full_path}"
  end

  def test_show_unpublished
    @page.update_columns(is_published: false)

    assert_exception_raised ActionController::RoutingError, 'Page Not Found at: ""' do
      get comfy_cms_render_page_path(cms_path: "")
    end
  end

  def test_show_with_erb_disabled
    assert_equal false, ComfortableMexicanSofa.config.allow_erb

    @site.pages.create!(
      label:          "erb",
      slug:           "erb",
      parent_id:      @page.id,
      layout_id:      @layout.id,
      is_published:   "1",
      fragments_attributes: [
        { identifier: "content",
          content:    "text <%= 2 + 2 %> text" }
      ]
    )
    get comfy_cms_render_page_path(cms_path: "erb")
    assert_response :success
    assert_match "text &lt;%= 2 + 2 %&gt; text", response.body
  end

  def test_show_with_irb_enabled
    ComfortableMexicanSofa.config.allow_erb = true

    @site.pages.create!(
      label:          "erb",
      slug:           "erb",
      parent_id:      @page.id,
      layout_id:      @layout.id,
      is_published:   "1",
      fragments_attributes: [
        { identifier: "content",
          content:    "text <%= 2 + 2 %> text" }
      ]
    )
    get comfy_cms_render_page_path(cms_path: "erb")
    assert_response :success
    assert_match "text 4 text", response.body
  end

  def test_show_with_translation
    @translation.update_column(:content_cache, "translation content")
    I18n.locale = @translation.locale

    assert_no_difference -> { @page.fragments.count } do
      get comfy_cms_render_page_path(cms_path: "")
      assert_equal "translation content", response.body
    end
  end

  def test_show_with_translation_not_found
    I18n.locale = :ja
    assert_exception_raised ActionController::RoutingError, 'Page Not Found at: ""' do
      get comfy_cms_render_page_path(cms_path: "")
    end
  end

  def test_show_with_translation_unpublished
    @translation.update_column(:is_published, false)
    I18n.locale = @translation.locale

    assert_exception_raised ActionController::RoutingError, 'Page Not Found at: ""' do
      get comfy_cms_render_page_path(cms_path: "")
    end
  end

  def test_with_translation_with_snippet
    translation = @page.translations.create!(
      locale: "ja",
      label:  "Test Translation",
      fragments_attributes: [
        { identifier: "content",
          tag:        "text",
          content:    "test {{cms:snippet default}} test" }
      ]
    )
    I18n.locale = translation.locale

    get comfy_cms_render_page_path(cms_path: "")
    assert_equal "test snippet content test", response.body
  end

end
