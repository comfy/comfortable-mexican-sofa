require_relative '../../../test_helper'

class ContentTagsCheckboxTest < ActiveSupport::TestCase

  setup do
    @page = comfy_cms_pages(:default)
  end

  def test_init
    tag = ComfortableMexicanSofa::Content::Tag::Checkbox.new(@page, "test")
    assert_equal "test", tag.identifier
  end

  def test_content
    frag = comfy_cms_fragments(:boolean)
    tag = ComfortableMexicanSofa::Content::Tag::Checkbox.new(@page, frag.identifier)
    assert_equal frag,          tag.fragment
    assert_equal frag.boolean,  tag.content
  end
end
