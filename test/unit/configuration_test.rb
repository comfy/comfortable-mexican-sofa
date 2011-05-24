require File.expand_path('../test_helper', File.dirname(__FILE__))

class ConfigurationTest < ActiveSupport::TestCase
  
  def test_configuration_presense
    assert config = ComfortableMexicanSofa.configuration
    assert_equal 'ComfortableMexicanSofa MicroCMS', config.cms_title
    assert_equal 'ComfortableMexicanSofa::HttpAuth', config.authentication
    assert_equal 'cms-admin', config.admin_route_prefix
    assert_equal '', config.content_route_prefix
    assert_equal 'pages', config.admin_route_redirect
    assert_equal false, config.enable_multiple_sites
    assert_equal false, config.enable_mirror_sites
    assert_equal false, config.allow_irb
    assert_equal true, config.enable_caching
    assert_equal false, config.enable_fixtures
    assert_equal File.expand_path('db/cms_fixtures', Rails.root), config.fixtures_path
    assert_equal 25, config.revisions_limit
  end
  
  def test_initialization_overrides
    ComfortableMexicanSofa.configuration.cms_title = 'New Title'
    assert_equal 'New Title', ComfortableMexicanSofa.configuration.cms_title
  end
  
  def test_version
    assert ComfortableMexicanSofa::VERSION
  end
  
end