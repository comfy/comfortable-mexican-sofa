# frozen_string_literal: true

require "rails_helper"

RSpec.describe Comfy::Cms::Page::ParentSelectComponent do
  describe "#call" do
    it "renders component" do
      cms_page = comfy_cms_sites(:default).pages.new
      form = ComfortableMexicanSofa::FormBuilder.new(:page, cms_page, vc_test_view_context, {})
      component = described_class.new(form: form)
      render_inline(component)
      expect(page).to have_css("comfy--cms--page--parent-select-component select")
    end
  end

  describe "#render?" do
    it "doesn't render if there are no options" do
      form = ComfortableMexicanSofa::FormBuilder.new(:page, comfy_cms_pages(:default), vc_test_view_context, {})
      component = described_class.new(form: form)
      expect(component.render?).to be(false)
    end

    it "returns true if there are options to show" do
      page = comfy_cms_sites(:default).pages.new
      form = ComfortableMexicanSofa::FormBuilder.new(:page, page, vc_test_view_context, {})
      component = described_class.new(form: form)
      expect(component.render?).to be(true)
    end
  end

  describe "#options" do
    it "outputs list of options" do
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

    it "hides options that would be invalid" do
      form = ComfortableMexicanSofa::FormBuilder.new(:page, comfy_cms_pages(:child), vc_test_view_context, {})
      component = described_class.new(form: form)
      expected = [
        [" Default Page", comfy_cms_pages(:default).id],
        [" ·  Sibling Page", comfy_cms_pages(:sibling).id]
      ]
      expect(component.options).to eq(expected)
    end
  end
end
