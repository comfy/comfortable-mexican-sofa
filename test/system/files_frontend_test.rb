# frozen_string_literal: true

require_relative "../test_helper"

class FilesFrontendTest < ApplicationSystemTestCase

  setup do
    @site     = comfy_cms_sites(:default)
    @layout   = comfy_cms_layouts(:default)
    @page     = comfy_cms_pages(:default)
  end

  def test_site_file_drag_and_drop
    skip
    # Dragging from iframe isn't supported by the chromedriver. This is not
    # possible to test at the moment.
    # See: https://github.com/SeleniumHQ/selenium/issues/810"
  end

  def test_page_file_drag_and_drop
    @layout.update_column(:content, <<~TEXT)
      {{ cms:files attachments, render: false }}
      {{ cms:text content }}
    TEXT

    comfy_cms_fragments(:default).update_column(:content, "")

    @page.update!(
      fragments_attributes: [{
        identifier: "attachments",
        tag:        "files",
        files:      fixture_file_upload("files/image.jpg", "image/jpg")
      }]
    )

    visit_p edit_comfy_admin_cms_site_page_path(@site, @page)

    text_field = find_field(name: "page[fragments_attributes][1][content]")
    find_link("image.jpg").drag_to(text_field)

    skip
    # Figure out why dragging doesn't really happen.
    assert_equal '{{ cms:page_file_link attachments, filename: "image.jpg", as: image }}', text_field.value
  end

end
