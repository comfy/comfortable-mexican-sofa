# frozen_string_literal: true

require "rails_helper"

RSpec.describe Comfy::Cms::Page::RedirectSelectComponent do
  describe "#call" do
    it "renders component" do
      form = ComfortableMexicanSofa::FormBuilder.new(:page, comfy_cms_pages(:default), vc_test_view_context, {})
      component = described_class.new(form: form)
      render_inline(component)

      expect(page).to have_css("comfy--cms--page--redirect-select-component")
      expect(page).to have_select(
        "Redirect to Page", with_options: ["― No Redirect ―"], disabled_options: [" Default Page"]
      )
    end
  end

  describe "#render?" do
    it "returns false if there are no options" do
      Comfy::Cms::Page.delete_all
      page = comfy_cms_sites(:default).pages.new
      form = ComfortableMexicanSofa::FormBuilder.new(:page, page, vc_test_view_context, {})
      component = described_class.new(form: form)
      expect(component.render?).to be(false)
    end

    it "returns true if there are options" do
      form = ComfortableMexicanSofa::FormBuilder.new(:page, comfy_cms_pages(:default), vc_test_view_context, {})
      component = described_class.new(form: form)
      expect(component.render?).to be(true)
    end
  end

  describe "#options" do
    it "returns list of options" do
      page = comfy_cms_sites(:default).pages.new
      form = ComfortableMexicanSofa::FormBuilder.new(:page, page, vc_test_view_context, {})
      component = described_class.new(form: form)
      expected = [
        [" Default Page", comfy_cms_pages(:default).id],
        [" ·  Child Page", comfy_cms_pages(:child).id],
        [" ·  Sibling Page", comfy_cms_pages(:sibling).id]
      ]
      expect(component.options).to eq(expected)
    end
  end
end
