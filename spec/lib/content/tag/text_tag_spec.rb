# frozen_string_literal: true

require "rails_helper"

RSpec.describe ComfortableMexicanSofa::Content::Tag::TextTag do
  include ActionView::TestCase::Behavior

  let(:page) { comfy_cms_pages(:default) }
  let(:frag) { comfy_cms_fragments(:default) }

  it "is registered with renderer" do
    expect(ComfortableMexicanSofa::Content::Renderer.tags["text"]).to eq(described_class)
  end

  describe ".new" do
    it "initializes tag" do
      tag = described_class.new(context: page, params: ["test"])
      expect(tag.identifier).to eq("test")
    end
  end

  describe "#form_field" do
    it "renders the field" do
      tag = described_class.new(context: page, params: [frag.identifier])
      output = tag.form_field("object_name", view, 0, &:itself)
      expect(Capybara.string(output)).to have_selector(
        :element, "input",
        value: "fragment-content {{cms:snippet default}}",
        type:  "text",
        name:  "object_name[fragments_attributes][0][content]",
        id:    "fragment-content",
        class: "form-control"
      )
    end
  end
end
