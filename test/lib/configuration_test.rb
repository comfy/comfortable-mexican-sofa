# encoding: utf-8

require_relative '../test_helper'

class ConfigurationTest < ActiveSupport::TestCase
  
  def test_configuration_presence
    assert config = ComfortableMexicanSofa.configuration
    assert_equal 'ComfortableMexicanSofa CMS Engine', config.cms_title
    assert_equal 'ApplicationController', config.base_controller
    assert_equal 'ComfortableMexicanSofa::HttpAuth', config.admin_auth
    assert_equal 'ComfortableMexicanSofa::DummyAuth', config.public_auth
    assert_equal '', config.admin_route_redirect
    assert_equal false, config.enable_fixtures
    assert_equal File.expand_path('db/cms_fixtures', Rails.root), config.fixtures_path
    assert_equal 25, config.revisions_limit
    assert_equal ({ 
      'en'    => 'English',
      'es'    => 'Español',
      'pt-BR' => 'Português Brasileiro',
      'zh-CN' => '简体中文',
      'ja'    => '日本語'
    }), config.locales
    assert_equal nil, config.admin_locale
    assert_equal nil, config.database_config
    assert_equal ({}), config.upload_file_options
    assert_equal nil, config.admin_cache_sweeper
    assert_equal false, config.allow_irb
    assert_equal nil, config.allowed_helpers
    assert_equal nil, config.allowed_partials
    assert_equal nil, config.hostname_aliases
  end
  
  def test_initialization_overrides
    ComfortableMexicanSofa.configuration.cms_title = 'New Title'
    assert_equal 'New Title', ComfortableMexicanSofa.configuration.cms_title
  end
  
  def test_version
    assert ComfortableMexicanSofa::VERSION
  end
  
end