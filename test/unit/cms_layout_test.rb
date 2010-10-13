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
    assert_has_errors_on layout, [:label, :content]
  end
  
  def test_options_for_select
    assert_equal ['Default Layout', 'Nested Layout', '. . Child Layout'], CmsLayout.options_for_select.collect{|t| t.first}
    assert_equal ['Default Layout', 'Nested Layout'], CmsLayout.options_for_select(cms_layouts(:child)).collect{|t| t.first}
    assert_equal ['Default Layout'], CmsLayout.options_for_select(cms_layouts(:nested)).collect{|t| t.first}
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
    merged_css = cms_layouts(:nested).css + cms_layouts(:child).css
    assert_equal merged_css, cms_layouts(:child).merged_css
  end
  
  def test_merged_js
    merged_js = cms_layouts(:nested).js + cms_layouts(:child).js
    assert_equal merged_js, cms_layouts(:child).merged_js
  end
  
end
