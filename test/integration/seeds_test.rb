# frozen_string_literal: true

require_relative "../test_helper"

class SeedsIntergrationTest < ActionDispatch::IntegrationTest

  setup do
    @site = comfy_cms_sites(:default)
    @site.update_columns(identifier: "sample-site")
  end

  def test_seeds_disabled
    assert_no_difference ["Comfy::Cms::Layout.count", "Comfy::Cms::Page.count", "Comfy::Cms::Snippet.count"] do
      get "/"
      assert_response :success

      assert_equal "Default Page", Comfy::Cms::Page.root.label
      assert_equal "Default Layout", Comfy::Cms::Layout.find_by_identifier("default").label
      assert_equal "Default Snippet", Comfy::Cms::Snippet.find_by_identifier("default").label
    end
  end

  def test_seeds_enabled
    ComfortableMexicanSofa.config.enable_seeds = true
    Comfy::Cms::Layout.destroy_all
    Comfy::Cms::Page.destroy_all
    Comfy::Cms::Snippet.destroy_all

    assert_difference "Comfy::Cms::Page.count", 3 do
      assert_difference "Comfy::Cms::Layout.count", 2 do
        assert_difference "Comfy::Cms::Snippet.count", 1 do
          get "/"
          assert_response :success

          assert_equal "Home Seed Page", Comfy::Cms::Page.root.label
          assert_equal "Default Seed Layout", Comfy::Cms::Layout.find_by_identifier("default").label
          assert_equal "Default Seed Snippet", Comfy::Cms::Snippet.find_by_identifier("default").label

          file_path = url_for(ActiveStorage::Blob.find_by(filename: "header.png"))
          file_path = file_path.sub("http://www.example.com", "")
          out = <<~HTML
            <html>
              <body>
                <img src='#{file_path}' alt='header.png'/>
                <p>Home Page Seed Contént
            Default Seed Snippet Content
            </p>


              </body>
            </html>

          HTML
          assert_equal out, response.body
        end
      end
    end
  end

  def test_fixtures_enabled_in_admin
    ComfortableMexicanSofa.config.enable_seeds = true
    Comfy::Cms::Layout.destroy_all
    Comfy::Cms::Page.destroy_all
    Comfy::Cms::Snippet.destroy_all

    assert_difference "Comfy::Cms::Page.count", 3 do
      assert_difference "Comfy::Cms::Layout.count", 2 do
        assert_difference "Comfy::Cms::Snippet.count", 1 do
          r :get, "/admin/sites/#{@site.id}/pages"
          assert_response :success
          assert_equal "CMS Seeds are enabled. All changes done here will be discarded.", flash[:warning]
        end
      end
    end
  end

end
