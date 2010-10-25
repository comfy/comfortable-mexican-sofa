require File.dirname(__FILE__) + '/../test_helper'

class CmsLayoutTest < ActiveSupport::TestCase
  
  def test_fixtures_validity
    CmsLayout.all.each do |layout|
      assert layout.valid?
    end
  end
  
  def test_validations
    layout = CmsLayout.create
    assert layout.errors.present?
    assert_has_errors_on layout, [:label, :slug, :content]
  end
  
  def test_options_for_select
    assert_equal ['Default Layout', 'Nested Layout', '. . Child Layout'],
      CmsLayout.options_for_select(cms_sites(:default)).collect{|t| t.first}
    assert_equal ['Default Layout', 'Nested Layout'],
      CmsLayout.options_for_select(cms_sites(:default), cms_layouts(:child)).collect{|t| t.first}
    assert_equal ['Default Layout'],
      CmsLayout.options_for_select(cms_sites(:default), cms_layouts(:nested)).collect{|t| t.first}
  end
  
  def test_app_layouts_for_select
    assert_equal ['cms_admin.html.erb'], CmsLayout.app_layouts_for_select
  end
  
  def test_merged_content
    parent_layout = cms_layouts(:nested)
    layout = cms_layouts(:child)
    assert_equal "<cms:page:header/>\n<cms:page:left_column>\n<cms:page:right_column>", layout.merged_content
    assert_equal "<cms:page:left_column>\n<cms:page:right_column>", layout.content
    
    parent_layout.update_attribute(:content, '<cms:page:whatever/>')
    layout.reload
    assert_equal "<cms:page:left_column>\n<cms:page:right_column>", layout.merged_content
  end
  
  def test_merged_css
    assert_equal "nested_css\nchild_css", cms_layouts(:child).merged_css
  end
  
  def test_merged_js
    assert_equal "nested_js\nchild_js", cms_layouts(:child).merged_js
  end
  
  def test_load_from_file
    assert !CmsLayout.load_from_file(cms_sites(:default), 'default')
    
    ComfortableMexicanSofa.configuration.seed_data_path = File.expand_path('../cms_seeds', File.dirname(__FILE__))
    
    assert !CmsLayout.load_from_file(cms_sites(:default), 'bogus')
    
    assert layout = CmsLayout.load_from_file(cms_sites(:default), 'default')
    assert_equal 'Default Layout', layout.label
    assert_equal '<html><cms:page:content/></html>', layout.content
    
    assert layout = CmsLayout.load_from_file(cms_sites(:default), 'nested')
    assert_equal 'Nested Layout', layout.label
    assert_equal '<div><cms:page:content/></div>', layout.content
    assert_equal '<html><div><cms:page:content/></div></html>', layout.merged_content
  end
  
end
