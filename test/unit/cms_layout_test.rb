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
  
end
