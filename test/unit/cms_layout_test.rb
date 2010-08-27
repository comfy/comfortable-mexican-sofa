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
  
end
