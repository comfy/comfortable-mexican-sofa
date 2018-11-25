# frozen_string_literal: true

require_relative "../test_helper"

class RenderCmsIntergrationTest < ActionDispatch::IntegrationTest

  def setup
    super
    Rails.application.routes.draw do
      get "/render-basic"           => "render_test#render_basic"
      get "/render-page"            => "render_test#render_page"
      get "/site-path/render-page"  => "render_test#render_page"
      get "/render-layout"          => "render_test#render_layout"
    end
    comfy_cms_layouts(:default).update_columns(content: "{{cms:text content}}")
    comfy_cms_pages(:child).update(fragments_attributes: [
      { identifier: "content", content: "TestBlockContent" }
    ])
  end

  def teardown
    Rails.application.reload_routes!
  end

  def create_site_b
    site = Comfy::Cms::Site.create!(
      identifier: "site-b",
      hostname:   "site-b.test"
    )
    layout = site.layouts.create!(
      identifier: "default",
      content:    "site-b {{cms:text content}}"
    )
    site.pages.create!(
      label:  "default",
      layout: layout,
      fragments_attributes: [{ identifier: "content", content: "SiteBContent" }]
    )
  end

  class ::RenderTestController < ApplicationController

    append_view_path(File.expand_path("../fixtures/views", File.dirname(__FILE__)))

    def render_basic
      case params[:type]
      when "text"
        render plain: "TestText"
      when "update"
        render :update do |page|
          page.alert("rendered text")
        end
      else
        render
      end
    end

    def render_page
      case params[:type]
      when "page_implicit"
        render
      when "page_explicit"
        render cms_page: "/test-page"
      when "page_explicit_with_status"
        render cms_page: "/test-page", status: 404
      when "page_explicit_with_site"
        render cms_page: "/", cms_site: "site-b"
      when "page_explicit_with_blocks"
        render cms_page: "/test-page", cms_fragments: {
          content: "custom page content"
        }
      else
        raise "Invalid or no param[:type] provided"
      end
    end

    def render_layout
      @test_value = "TestValue"
      case params[:type]
      when "layout_defaults"
        render cms_layout: "default"
      when "layout"
        render cms_layout: "default", cms_fragments: {
          content:    "TestText",
          content_b:  { partial: "render_test/test" },
          content_c:  { template: "render_test/render_layout" }
        }
      when "layout_with_status"
        render cms_layout: "default", status: 404
      when "layout_invalid"
        render cms_layout: "invalid"
      when "layout_defaults_with_site"
        render cms_layout: "default", cms_site: "site-b"
      when "layout_with_action"
        render cms_layout: "default", action: :new
      else
        raise "Invalid or no param[:type] provided"
      end
    end

    def new; end

  end

  # -- Basic Render Tests ------------------------------------------------------
  def test_text
    get "/render-basic?type=text"
    assert_response :success
    assert_equal "TestText", response.body
  end

  def test_implicit_cms_page_failure
    Comfy::Cms::Site.destroy_all
    assert_exception_raised ActionView::MissingTemplate do
      get "/render-basic"
    end
  end

  # -- Page Render Test --------------------------------------------------------
  def test_implicit_cms_page
    page = comfy_cms_pages(:child)
    page.update(slug: "render-basic")
    get "/render-basic?type=page_implicit"
    assert_response :success
    assert assigns(:cms_site)
    assert assigns(:cms_layout)
    assert assigns(:cms_page)
    assert_equal page, assigns(:cms_page)
    assert_equal "TestBlockContent", response.body
  end

  def test_implicit_cms_page_with_site_path
    comfy_cms_sites(:default).update_column(:path, "site-path")
    comfy_cms_pages(:child).update(slug: "render-page")
    get "/site-path/render-page?type=page_implicit"
    assert_response :success
    assert_equal "TestBlockContent", response.body
  end

  def test_explicit_cms_page
    page = comfy_cms_pages(:child)
    page.update(slug: "test-page")
    get "/render-page?type=page_explicit"
    assert_response :success
    assert assigns(:cms_site)
    assert assigns(:cms_layout)
    assert assigns(:cms_page)
    assert_equal page, assigns(:cms_page)
    assert_equal "TestBlockContent", response.body
  end

  def test_explicit_cms_page_with_status
    page = comfy_cms_pages(:child)
    page.update(slug: "test-page")
    get "/render-page?type=page_explicit_with_status"
    assert_response :not_found
    assert assigns(:cms_site)
    assert assigns(:cms_layout)
    assert assigns(:cms_page)
    assert_equal page, assigns(:cms_page)
    assert_equal "TestBlockContent", response.body
  end

  def test_explicit_cms_page_failure
    page = comfy_cms_pages(:child)
    page.update(slug: "invalid")
    assert_exception_raised ComfortableMexicanSofa::MissingPage do
      get "/render-page?type=page_explicit"
    end
  end

  def test_explicit_with_site
    create_site_b
    get "/render-page?type=page_explicit_with_site"
    assert_response :success
    assert assigns(:cms_site)
    assert_equal "site-b", assigns(:cms_site).identifier
    assert_equal "site-b SiteBContent", response.body
  end

  def test_explicit_with_site_failure
    assert_exception_raised ComfortableMexicanSofa::MissingSite do
      get "/render-page?type=page_explicit_with_site"
    end
  end

  def test_explicit_with_page_blocks
    page = comfy_cms_pages(:child)
    page.update(slug: "test-page")
    get "/render-page?type=page_explicit_with_blocks"
    assert_response :success
    assert_equal "custom page content", response.body
  end

  def test_explicit_with_translation
    I18n.locale = :fr

    page = comfy_cms_pages(:child)
    page.update(slug: "test-page")

    # pointing translation to our page here
    translation = comfy_cms_translations(:default)
    translation.update_column(:page_id, page.id)

    get "/render-page?type=page_explicit"
    assert_equal "translated content", response.body
  end

  # -- Layout Render Tests -----------------------------------------------------
  def test_cms_layout_defaults
    get "/render-layout?type=layout_defaults"
    assert_response :success
    assert_equal "TestTemplate TestValue", response.body
    assert assigns(:cms_site)
    assert assigns(:cms_layout)
    assert_equal comfy_cms_layouts(:default), assigns(:cms_layout)
  end

  def test_cms_layout
    content = "{{cms:text content}} {{cms:text content_b}} {{cms:text content_c}}"
    comfy_cms_layouts(:default).update_columns(content: content)
    get "/render-layout?type=layout"
    assert_response :success
    assert_equal "TestText TestPartial TestValue TestTemplate TestValue", response.body
    assert assigns(:cms_site)
    assert assigns(:cms_layout)
    assert_equal comfy_cms_layouts(:default), assigns(:cms_layout)
  end

  def test_cms_layout_with_status
    get "/render-layout?type=layout_with_status"
    assert_response 404
    assert_equal "TestTemplate TestValue", response.body
    assert assigns(:cms_site)
    assert assigns(:cms_layout)
    assert_equal comfy_cms_layouts(:default), assigns(:cms_layout)
  end

  def test_cms_layout_with_action
    content = "{{cms:text content}} {{cms:text content_b}} {{cms:text content_c}}"
    comfy_cms_layouts(:default).update_columns(content: content)
    get "/render-layout?type=layout_with_action"
    assert_response :success
    assert_equal "Can render CMS layout and specify action\n  ", response.body
    assert assigns(:cms_site)
    assert assigns(:cms_layout)
    assert_equal comfy_cms_layouts(:default), assigns(:cms_layout)
  end

  def test_cms_layout_failure
    assert_exception_raised ComfortableMexicanSofa::MissingLayout do
      get "/render-layout?type=layout_invalid"
    end
  end

  def test_cms_layout_defaults_with_site
    create_site_b
    get "/render-layout?type=layout_defaults_with_site"
    assert_response :success
    assert assigns(:cms_site)
    assert_equal "site-b", assigns(:cms_site).identifier
    assert_equal "site-b TestTemplate TestValue", response.body
  end

  def test_cms_layout_defaults_with_site_failure
    assert_exception_raised ComfortableMexicanSofa::MissingSite do
      get "/render-layout?type=layout_defaults_with_site"
    end
  end

end
