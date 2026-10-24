# frozen_string_literal: true

require "rails_helper"

RSpec.describe ComfortableMexicanSofa::Content::NumberTag do
  include ActionView::TestCase::Behavior

  let(:page) { comfy_cms_pages(:default) }

  it "is registered with renderer" do
    expect(ComfortableMexicanSofa::Content::Renderer.tags["number"]).to eq(described_class)
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
      output = Capybara.string(tag.form_field("object_name", view, 0, &:itself))

      expect(output).to have_selector(
        :element, "input",
        type: "number",
        name: "object_name[fragments_attributes][0][content]",
        id:   "fragment-test"
      )
    end
  end
end
