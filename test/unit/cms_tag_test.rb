require File.dirname(__FILE__) + '/../test_helper'

class CmsTagTest < ActiveSupport::TestCase
  
  def test_method_find_cms_tags
    content = cms_layouts(:default).content
    assert_equal [
      '<cms:page:content/>',
      '<cms:page:title:string/>',
      '<cms:page:number:integer/>'
    ], CmsTag.find_cms_tags(content)
  end
  
  def test_method_initialize_tags
    raise CmsTag.initialize_tags(cms_layouts(:default).content).inspect
  end
  
end
