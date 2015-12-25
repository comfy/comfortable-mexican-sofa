# encoding: utf-8

require_relative '../test_helper'

class FixturesIntergrationTest < ActionDispatch::IntegrationTest

  def setup
    comfy_cms_sites(:default).update_columns(:identifier => 'sample-site')
  end

  def test_fixtures_disabled
    assert_no_difference ['Comfy::Cms::Layout.count', 'Comfy::Cms::Page.count', 'Comfy::Cms::Snippet.count'] do
      get '/'
      assert_response :success

      assert_equal 'Default Page', Comfy::Cms::Page.root.label
      assert_equal 'Default Layout', Comfy::Cms::Layout.find_by_identifier('default').label
      assert_equal 'Default Snippet', Comfy::Cms::Snippet.find_by_identifier('default').label
    end
  end

  def test_fixtures_enabled
    ComfortableMexicanSofa.config.enable_fixtures = true
    Comfy::Cms::Layout.destroy_all
    Comfy::Cms::Page.destroy_all
    Comfy::Cms::Snippet.destroy_all

    assert_difference 'Comfy::Cms::Page.count', 2 do
      assert_difference 'Comfy::Cms::Layout.count', 2 do
        assert_difference 'Comfy::Cms::Snippet.count', 1 do
          get '/'
          assert_response :redirect
          assert_redirected_to '/child'
          follow_redirect!

          assert_equal 'Home Fixture Page', Comfy::Cms::Page.root.label
          assert_equal 'Default Fixture Layout', Comfy::Cms::Layout.find_by_identifier('default').label
          assert_equal 'Default Fixture Snippet', Comfy::Cms::Snippet.find_by_identifier('default').label

          file_path = Comfy::Cms::File.find_by(:file_file_name => 'thumbnail.png').file.url

          assert_equal "<html>\n  <body>\n    #{file_path}\n<div class='left'>Child Page Left Fixture Content</div>\n<div class='right'>Child Page Right Fixture Content</div>\n  </body>\n</html>", response.body
        end
      end
    end
  end

  def test_fixtures_enabled_in_admin
    ComfortableMexicanSofa.config.enable_fixtures = true
    Comfy::Cms::Layout.destroy_all
    Comfy::Cms::Page.destroy_all
    Comfy::Cms::Snippet.destroy_all

    assert_difference 'Comfy::Cms::Page.count', 2 do
      assert_difference 'Comfy::Cms::Layout.count', 2 do
        assert_difference 'Comfy::Cms::Snippet.count', 1 do
           http_auth :get, "/admin/sites/#{comfy_cms_sites(:default).id}/pages"
           assert_response :success
           assert_equal 'CMS Fixtures are enabled. All changes done here will be discarded.', flash[:danger]
        end
      end
    end
  end

end
