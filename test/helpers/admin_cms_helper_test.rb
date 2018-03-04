# frozen_string_literal: true

require_relative "../test_helper"

class AdminCmsHelpersTest < ActionView::TestCase

  include Comfy::Admin::CmsHelper

  setup do
    @attachment = comfy_cms_files(:default).attachment
  end

  def test_cms_page_file_link_tag
    actual = cms_page_file_link_tag(fragment_id: "test", attachment: @attachment, multiple: false)
    assert_equal "{{ cms:page_file_link test, as: image }}", actual
  end

  def test_cms_page_file_link_tag_non_image
    @attachment.blob.update_column(:content_type, "application/pdf")
    actual = cms_page_file_link_tag(fragment_id: "test", attachment: @attachment, multiple: false)
    assert_equal "{{ cms:page_file_link test }}", actual
  end

  def test_cms_page_file_link_multiple
    actual = cms_page_file_link_tag(fragment_id: "test", attachment: @attachment, multiple: true)
    assert_equal %q({{ cms:page_file_link test, filename: "default.jpg", as: image }}), actual
  end

end
