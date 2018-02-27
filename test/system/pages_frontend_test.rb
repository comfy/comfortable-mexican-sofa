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

end
