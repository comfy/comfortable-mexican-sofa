require_relative '../test_helper'

class CmsSearchTest < ActiveSupport::TestCase

  def test_search
    results = Comfy::Cms::Search.new(Comfy::Cms::Page, "Default").results
    assert_equal(Comfy::Cms::Page.find_by_label('Default Page'), results.first)
  end

end
