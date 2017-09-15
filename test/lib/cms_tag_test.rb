require_relative '../test_helper'

class TagTest < ActiveSupport::TestCase

  def test_something
    params = 'fragment_name, type: something'
    tag = FragmentTag.send(:new, 'cms_fragment', params, Liquid::ParseContext.new)
    assert_equal [], tag.params
  end

end