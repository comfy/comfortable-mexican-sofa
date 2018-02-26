# frozen_string_literal: true

require_relative "../test_helper"

class SnippetsFrontendTest < ApplicationSystemTestCase

  setup do
    @site = comfy_cms_sites(:default)
  end

  def test_new_identifier
    visit_p new_comfy_admin_cms_site_snippet_path(@site)
    fill_in "Label", with: "Test Snippet"
    assert_equal "test-snippet", find_field("Identifier").value
  end

end
