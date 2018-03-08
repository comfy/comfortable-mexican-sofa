# frozen_string_literal: true

require_relative "../test_helper"

class PagesFrontendTest < ApplicationSystemTestCase

  setup do
    @site = comfy_cms_sites(:default)
  end

  def test_new_identifier
    visit_p new_comfy_admin_cms_site_page_path(@site)
    fill_in "Label", with: "Test Page"
    assert_equal "test-page", find_field("Slug").value
  end

  def test_change_to_invalid_fragment_and_back
    valid_layout = comfy_cms_layouts(:default)
    valid_layout.update_column(:content, "{{ cms:text content }}")

    invalid_layout = comfy_cms_layouts(:child)
    invalid_layout.update_column(:content, "{{ cms:wysiwyg }}")

    cms_page = comfy_cms_pages(:default)
    visit_p edit_comfy_admin_cms_site_page_path(@site, cms_page)
    assert_field "page[fragments_attributes][0][content]", type: "text"

    select invalid_layout.label, from: "Layout"
    assert_equal "Missing identifier for fragment tag: {{ cms:wysiwyg }}", find(".alert-danger").text.strip

    select valid_layout.label, from: "Layout"
    assert_field "page[fragments_attributes][0][content]", type: "text"
  end

end
