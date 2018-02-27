# frozen_string_literal: true

require_relative "../test_helper"

class FilesFrontendTest < ApplicationSystemTestCase

  setup do
    @site = comfy_cms_sites(:default)
  end

  def test_site_file_drag_and_drop
    file = comfy_cms_files(:default)
    file.attachment = ActiveStorage::Blob.create_after_upload!(
      io: file_fixture("image.jpg").open, filename: "image.jpg", content_type: "image/jpg"
    )
    file.save!

    comfy_cms_layouts(:default).update!(content: "{{ cms:text content }}")
    visit_p edit_comfy_admin_cms_site_page_path(site_id: @site, id: comfy_cms_pages(:default))
    click_link title: "Open library"

    skip "Drag'n'drop from iframe to parent has issues:
https://github.com/SeleniumHQ/selenium/issues/810"
    drop_target = content_field
    within_frame(:css, ".cms-files-modal iframe") do
      find_link(file.label).drag_to(drop_target)
    end
    assert_equal "{{ cms:file_link #{file.id} }}", content_field.value
  end

  def test_page_file_drag_and_drop
    # Upload a page file.
    comfy_cms_layouts(:default).update!(content: <<~TEXT)
      {{ cms:text content }}
      {{ cms:files attachments, render: false }}
    TEXT
    visit_p edit_comfy_admin_cms_site_page_path(site_id: @site, id: comfy_cms_pages(:default))
    attach_file Rails.root.join("test/fixtures/files/image.jpg"),
                name: "page[fragments_attributes][1][files][]", multiple: true
    click_button I18n.t("comfy.admin.cms.pages.form.update")
    assert_link "image.jpg"

    # Dragging the link should generate CMS markup.
    skip "Drag'n'drop does not work for some reason"
    find_link("image.jpg").drag_to(content_field)
    assert_equal '{{ cms:page_file_link attachments, filename: "image.jpg", as: image }}', content_field.value
  end

private

  def content_field
    find_field(name: "page[fragments_attributes][0][content]")
  end

end
