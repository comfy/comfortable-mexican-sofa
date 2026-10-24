# frozen_string_literal: true

require "rails_helper"

RSpec.describe ComfortableMexicanSofa::Content::TextareaTag do
  include ActionView::TestCase::Behavior

  let(:page) { comfy_cms_pages(:default) }

  it "is registered with renderer" do
    expect(ComfortableMexicanSofa::Content::Renderer.tags["textarea"]).to eq(described_class)
  end

  describe ".new" do
    it "initializes tag" do
      tag = described_class.new(context: page, params: ["test"])
      expect(tag.identifier).to eq("test")
    end
  end

  describe "#form_field" do
    it "renders the field" do
      tag = described_class.new(context: page, params: ["test"])
      output = tag.form_field("object_name", view, 0, &:itself)
      expect(Capybara.string(output)).to have_selector(:element, "textarea",
        name:               "object_name[fragments_attributes][0][content]",
        id:                 "fragment-test",
        "data-cms-cm-mode": "text/html"
      )
    end
  end
end
