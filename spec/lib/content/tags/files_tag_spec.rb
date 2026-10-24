# frozen_string_literal: true

require "rails_helper"

RSpec.describe ComfortableMexicanSofa::Content::FilesTag do
  include ActionView::TestCase::Behavior

  let(:page) { comfy_cms_pages(:default) }
  let(:frag) { comfy_cms_fragments(:file) }

  it "is registered with renderer" do
    expect(ComfortableMexicanSofa::Content::Renderer.tags["files"]).to eq(described_class)
  end

  describe ".new" do
    it "initializes tag" do
      tag = described_class.new(context: page, params: ["test"])
      expect(tag.identifier).to eq("test")
      expect(tag.as).to eq("url")
      expect(tag.variant_options).to eq({})
    end
  end

  describe "#form_field" do
    it "renders the field" do
      tag = described_class.new(context: page, params: [frag.identifier])
      output = Capybara.string(tag.form_field("object_name", view, 0, &:itself))
      expect(output).to have_selector(:element, "input",
        type: "file",
        name: "object_name[fragments_attributes][0][files]",
        id:   "fragment-file"
      )
      expect(output).to have_css("comfy--cms--form-fragment-files-component .attachment")
    end
  end
end
