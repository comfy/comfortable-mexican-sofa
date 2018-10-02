# frozen_string_literal: true

require_relative "../../../test_helper"

class Comfy::Cms::ContentControllerJsonTest < ActionDispatch::IntegrationTest

  setup do
    @site         = comfy_cms_sites(:default)
    @layout       = comfy_cms_layouts(:default)
    @page         = comfy_cms_pages(:default)
    @translation  = comfy_cms_translations(:default)
  end

  def test_show_as_json
    setup_json_config({})
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
    assert_nil                    json_response["fragments"]
  end

  def test_show_as_json_with_include
    setup_json_config({
      include: [:fragments]
    })
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
    assert_equal 4,               json_response["fragments"].length
  end

  def setup_json_config(json_options = {})
    ComfortableMexicanSofa.configure do |config|
      config.cms_title            = "ComfortableMexicanSofa CMS Engine"
      config.admin_auth           = "ComfortableMexicanSofa::AccessControl::AdminAuthentication"
      config.admin_authorization  = "ComfortableMexicanSofa::AccessControl::AdminAuthorization"
      config.public_auth          = "ComfortableMexicanSofa::AccessControl::PublicAuthentication"
      config.public_authorization = "ComfortableMexicanSofa::AccessControl::PublicAuthorization"
      config.admin_route_redirect = ""
      config.enable_seeds         = false
      config.seeds_path           = File.expand_path("db/cms_seeds", Rails.root)
      config.revisions_limit      = 25
      config.locales              = {
        "en" => "English",
        "es" => "Español"
      }
      config.admin_locale         = nil
      config.admin_cache_sweeper  = nil
      config.allow_erb            = false
      config.allowed_helpers      = nil
      config.allowed_partials     = nil
      config.allowed_templates    = nil
      config.hostname_aliases     = nil
      config.reveal_cms_partials  = false
      config.public_cms_path      = nil
      config.content_json_options = json_options
    end
  end
end
