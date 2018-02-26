# frozen_string_literal: true

require_relative "../test_helper"

class SitesFrontendTest < ApplicationSystemTestCase

  def test_new_identifier
    visit_p new_comfy_admin_cms_site_path
    fill_in "Label", with: "Test Site"
    assert_equal "test-site", find_field("Identifier").value
  end

end
