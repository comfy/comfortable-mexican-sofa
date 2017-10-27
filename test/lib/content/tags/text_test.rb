require_relative '../../../test_helper'

class ContentTagsTextTest < ActiveSupport::TestCase

  setup do
    @page = comfy_cms_pages(:default)
  end

  def test_init
    tag = ComfortableMexicanSofa::Content::Tag::Text.new(@page, "test")
    assert_equal "test", tag.identifier
  end
end
