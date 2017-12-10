require_relative "../../../test_helper"

class ContentTagsDateTest < ActiveSupport::TestCase

  setup do
    @page = comfy_cms_pages(:default)
  end

  def test_init
    tag = ComfortableMexicanSofa::Content::Tag::Date.new(@page, "test")
    assert_equal "test", tag.identifier
  end

  def test_content
    frag = comfy_cms_fragments(:datetime)
    tag = ComfortableMexicanSofa::Content::Tag::Date.new(@page, frag.identifier)
    assert_equal frag,          tag.fragment
    assert_equal frag.datetime, tag.content
  end

end
