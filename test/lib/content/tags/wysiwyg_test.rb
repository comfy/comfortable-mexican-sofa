require_relative '../../../test_helper'

class ContentTagsWysiwygTest < ActiveSupport::TestCase

  setup do
    @page = comfy_cms_pages(:default)
  end

  def test_init
    tag = ComfortableMexicanSofa::Content::Tag::Wysiwyg.new(@page, "test")
    assert_equal "test", tag.identifier
  end
end
