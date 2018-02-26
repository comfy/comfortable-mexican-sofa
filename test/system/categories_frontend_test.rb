# frozen_string_literal: true

require_relative "../test_helper"

class CategoriesFrontendTest < ApplicationSystemTestCase

  setup do
    @site = comfy_cms_sites(:default)
  end

  def test_category_management
    visit_p comfy_admin_cms_site_snippets_path(@site)

    find("button.toggle-cat-edit").click
    selector = "form#new-category input[name='category[label]']"
    assert_selector(selector)

    # creating a new category
    find(selector).set("Test Category")
    click_button("Create Category")
    assert_selector("a.btn", text: "Test Category")

    # editing existing category
    click_link("Test Category")
    selector = "form.edit-category input[name='category[label]']"
    assert_selector(selector)
    find(selector).set("Updated Category")
    click_button("Update Category")
    assert_selector("a.btn", text: "Updated Category")

    # Deleting category
    accept_alert do
      click_link("Delete Category")
    end

    refute_selector("a.btn", text: "Updated Category")
  end

end
