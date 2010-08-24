require File.dirname(__FILE__) + '/../test_helper'

class CmsPageTest < ActiveSupport::TestCase
  
  def test_render
    page = cms_pages(:default)
    assert_equal 'Text Content', page.content
  end
  
end
