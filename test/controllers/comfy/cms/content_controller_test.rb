require_relative '../../../test_helper'

class Comfy::Cms::ContentControllerTest < ActionController::TestCase

  def test_show
    get :show, :cms_path => ''
    assert_equal comfy_cms_sites(:default), assigns(:cms_site)
    assert_equal comfy_cms_layouts(:default), assigns(:cms_layout)
    assert_equal comfy_cms_pages(:default), assigns(:cms_page)

    assert_response :success
    assert_equal rendered_content_formatter(
      '
      layout_content_a
      default_page_text_content_a
      default_snippet_content
      default_page_text_content_b
      layout_content_b
      default_snippet_content
      layout_content_c'
    ), response.body
    assert_equal 'text/html', response.content_type
  end

  def test_show_default_html
    @request.headers["Accept"] = "*/*"
    get :show, :cms_path => ''
    assert_response :success
    assert_equal 'text/html', response.content_type
  end

  def test_show_as_json
    get :show, :cms_path => '', :format => 'json'
    assert_response :success
    assert_equal 'application/json', response.content_type

    content = rendered_content_formatter(
      '
      layout_content_a
      default_page_text_content_a
      default_snippet_content
      default_page_text_content_b
      layout_content_b
      default_snippet_content
      layout_content_c'
    )
    page = comfy_cms_pages(:default)
    json_response = JSON.parse(response.body)
    assert_equal page.id,         json_response['id']
    assert_equal page.site.id,    json_response['site_id']
    assert_equal page.layout.id,  json_response['layout_id']
    assert_equal nil,             json_response['parent_id']
    assert_equal nil,             json_response['target_page_id']
    assert_equal 'Default Page',  json_response['label']
    assert_equal nil,             json_response['slug']
    assert_equal '/',             json_response['full_path']
    assert_equal content,         json_response['content_cache']
    assert_equal 0,               json_response['position']
    assert_equal 1,               json_response['children_count']
    assert_equal true,            json_response['is_published']
  end

  def test_show_with_custom_mimetype
    layout = comfy_cms_sites(:default).layouts.create!(
      :label      => 'RSS Layout',
      :identifier => 'rss-layout',
      :content    => '{{cms:field:mime_type}}{{cms:page:content}}',
    )
    page = comfy_cms_sites(:default).pages.create!(
      :label          => 'rss',
      :slug           => 'rss',
      :parent_id      => comfy_cms_pages(:default).id,
      :layout_id      => layout.id,
      :is_published   => true,
      :blocks_attributes => [
        { :identifier => 'content',
          :content    => 'content' },
        { :identifier => 'mime_type',
          :content    => 'application/rss+xml' }
      ]
    )
    get :show, :cms_path => 'rss'
    assert_response :success
    assert_equal 'application/rss+xml', response.content_type
  end

  def test_show_with_app_layout
    comfy_cms_layouts(:default).update_columns(:app_layout => 'comfy/admin/cms')
    get :show, :cms_path => ''
    assert_response :success
    assert assigns(:cms_page)
    assert_select "body.c-comfy-cms-content.a-show"
  end

  def test_show_with_xhr
    comfy_cms_layouts(:default).update_columns(:app_layout => 'cms_admin')
    xhr :get, :show, :cms_path => ''
    assert_response :success
    assert assigns(:cms_page)
    assert_no_select "body.c-comfy-cms-content.a-show"
  end

  def test_show_not_found
    assert_exception_raised ActionController::RoutingError, 'Page Not Found at: "doesnotexist"' do
      get :show, :cms_path => 'doesnotexist'
    end
  end

  def test_show_not_found_with_custom_404
    page = comfy_cms_sites(:default).pages.create!(
      :label          => '404',
      :slug           => '404',
      :parent_id      => comfy_cms_pages(:default).id,
      :layout_id      => comfy_cms_layouts(:default).id,
      :is_published   => '1',
      :blocks_attributes => [
        { :identifier => 'default_page_text',
          :content    => 'custom 404 page content' }
      ]
    )
    assert_equal '/404', page.full_path
    assert page.is_published?
    get :show, :cms_path => 'doesnotexist'
    assert_response 404
    assert assigns(:cms_page)
    assert_match /custom 404 page content/, response.body
  end

  def test_show_with_no_site
    Comfy::Cms::Site.destroy_all

    assert_exception_raised ActionController::RoutingError, 'Site Not Found' do
      get :show, :cms_path => ''
    end
  end

  def test_show_with_no_layout
    Comfy::Cms::Layout.destroy_all

    get :show, :cms_path => ''
    assert_response 404
    assert_equal 'Layout Not Found', response.body
  end

  def test_show_with_redirect
    comfy_cms_pages(:child).update_columns(:target_page_id => comfy_cms_pages(:default).id)
    assert_equal comfy_cms_pages(:default), comfy_cms_pages(:child).target_page
    get :show, :cms_path => 'child-page'
    assert_response :redirect
    assert_redirected_to comfy_cms_pages(:default).url
  end

  def test_show_unpublished
    page = comfy_cms_pages(:default)
    page.update_columns(:is_published => false)

    assert_exception_raised ActionController::RoutingError, 'Page Not Found at: ""' do
      get :show, :cms_path => ''
    end
  end

  def test_show_with_irb_disabled
    assert_equal false, ComfortableMexicanSofa.config.allow_irb

    irb_page = comfy_cms_sites(:default).pages.create!(
      :label          => 'irb',
      :slug           => 'irb',
      :parent_id      => comfy_cms_pages(:default).id,
      :layout_id      => comfy_cms_layouts(:default).id,
      :is_published   => '1',
      :blocks_attributes => [
        { :identifier => 'default_page_text',
          :content    => 'text <%= 2 + 2 %> text' }
      ]
    )
    get :show, :cms_path => 'irb'
    assert_response :success
    assert_match "text &lt;%= 2 + 2 %&gt; text", response.body
  end

  def test_show_with_irb_enabled
    ComfortableMexicanSofa.config.allow_irb = true

    irb_page = comfy_cms_sites(:default).pages.create!(
      :label          => 'irb',
      :slug           => 'irb',
      :parent_id      => comfy_cms_pages(:default).id,
      :layout_id  => comfy_cms_layouts(:default).id,
      :is_published   => '1',
      :blocks_attributes => [
        { :identifier => 'default_page_text',
          :content    => 'text <%= 2 + 2 %> text' }
      ]
    )
    get :show, :cms_path => 'irb'
    assert_response :success
    assert_match "text 4 text", response.body
  end

  def test_render_sitemap
    get :render_sitemap, :format => :xml
    assert_response :success
    assert_match '<loc>//test.host/child-page</loc>', response.body
  end

  def test_render_sitemap_with_path
    site = comfy_cms_sites(:default)
    site.update_columns(:path => 'en')

    get :render_sitemap, :cms_path => site.path, :format => :xml
    assert_response :success
    assert_equal comfy_cms_sites(:default), assigns(:cms_site)
    assert_match '<loc>//test.host/en/child-page</loc>', response.body
  end

  def test_render_sitemap_with_path_invalid_with_single_site
    site = comfy_cms_sites(:default)
    site.update_columns(:path => 'en')

    assert_exception_raised ActionController::RoutingError, 'Site Not Found' do
      get :render_sitemap, :cms_path => 'fr', :format => :xml
    end
  end

end
