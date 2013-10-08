# encoding: utf-8

require_relative '../test_helper'

class FixturesIntergrationTest < ActionDispatch::IntegrationTest
  
  def setup
    cms_sites(:default).update_columns(:identifier => 'sample-site')
  end
  
  def test_fixtures_disabled
    assert_no_difference ['Cms::Layout.count', 'Cms::Page.count', 'Cms::Snippet.count'] do
      get '/'
      assert_response :success
      
      assert_equal 'Default Page', Cms::Page.root.label
      assert_equal 'Default Layout', Cms::Layout.find_by_identifier('default').label
      assert_equal 'Default Snippet', Cms::Snippet.find_by_identifier('default').label
    end
  end
  
  def test_fixtures_enabled
    ComfortableMexicanSofa.config.enable_fixtures = true
    Cms::Layout.destroy_all
    Cms::Page.destroy_all
    Cms::Snippet.destroy_all
    
    assert_difference 'Cms::Page.count', 2 do
      assert_difference 'Cms::Layout.count', 2 do
        assert_difference 'Cms::Snippet.count', 1 do
          get '/'
          assert_response :redirect
          assert_redirected_to '//test.host/child'
          follow_redirect!
          
          assert_equal 'Home Fixture Page', Cms::Page.root.label
          assert_equal 'Default Fixture Layout', Cms::Layout.find_by_identifier('default').label
          assert_equal 'Default Fixture Snippet', Cms::Snippet.find_by_identifier('default').label
          
          assert_equal "<html>\n  <body>\n    <div class='left'> Child Page Left Fixture Content </div>\n<div class='right'> Child Page Right Fixture Content </div>\n  </body>\n</html>", response.body
        end
      end
    end
  end
  
  def test_fixtures_enabled_in_admin
    ComfortableMexicanSofa.config.enable_fixtures = true
    Cms::Layout.destroy_all
    Cms::Page.destroy_all
    Cms::Snippet.destroy_all
    
    assert_difference 'Cms::Page.count', 2 do
      assert_difference 'Cms::Layout.count', 2 do
        assert_difference 'Cms::Snippet.count', 1 do
           http_auth :get, "/admin/sites/#{cms_sites(:default).id}/pages"
           assert_response :success
           assert_equal 'CMS Fixtures are enabled. All changes done here will be discarded.', flash[:error]
        end
      end
    end
  end
  
end