require File.dirname(__FILE__) + '/../test_helper'

class CmsConfigurationTest < ActiveSupport::TestCase
  
  def test_configuration_presense
    assert config = ComfortableMexicanSofa.configuration
    assert_equal 'ComfortableMexicanSofa', config.cms_title
    assert_equal 'CmsHttpAuthentication', config.authentication
    assert_equal false, config.multiple_sites
  end
  
  def test_initialization_overrides
    ComfortableMexicanSofa.configuration.cms_title = 'New Title'
    assert_equal 'New Title', ComfortableMexicanSofa.configuration.cms_title
  end
  
end