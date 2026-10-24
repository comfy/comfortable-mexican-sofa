# frozen_string_literal: true

require "rails_helper"

RSpec.describe ComfortableMexicanSofa::Content::MarkdownTag do
  include ActionView::TestCase::Behavior

  let(:page) { comfy_cms_pages(:default) }
  let(:frag) { comfy_cms_fragments(:default) }

  it "is registered with renderer" do
    expect(ComfortableMexicanSofa::Content::Renderer.tags["markdown"]).to eq(described_class)
  end

  describe ".new" do
    it "initializes tag" do
      tag = described_class.new(context: page, params: ["test"])
      expect(tag.identifier).to eq("test")
    end
  end

  describe "#render" do
    it "outputs html from markdown" do
      frag.update_column(:content, "**test**")
      tag = described_class.new(context: page, params: [frag.identifier])
      expect(tag.render).to eq("<p><strong>test</strong></p>\n")
    end

    it "renders nothing if render flag is false" do
      tag = described_class.new(context: page, params: [frag.identifier, "render" => "false"])
      expect(tag.render).to eq("")
    end
  end

  describe "#form_field" do
    it "renders the field" do
      tag = described_class.new(context: page, params: ["test"])
      output = tag.form_field("object_name", view, 0, &:itself)
      expect(Capybara.string(output)).to have_selector(:element, "textarea",
        name:               "object_name[fragments_attributes][0][content]",
        id:                 "fragment-test",
        "data-cms-cm-mode": "text/x-markdown"
      )
    end
  end
end
