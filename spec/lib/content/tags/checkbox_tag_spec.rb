# frozen_string_literal: true

require "rails_helper"

RSpec.describe ComfortableMexicanSofa::Content::CheckboxTag do
  include ActionView::TestCase::Behavior

  let(:page) { comfy_cms_pages(:default) }
  let(:frag) { comfy_cms_fragments(:boolean) }

  it "is registered with renderer" do
    expect(ComfortableMexicanSofa::Content::Renderer.tags["checkbox"]).to eq(described_class)
  end

  describe ".new" do
    it "initializes tag" do
      tag = described_class.new(context: page, params: ["test"])
      expect(tag.identifier).to eq("test")
    end
  end

  describe "#content" do
    it "returns boolean content of the fragment" do
      tag = described_class.new(context: page, params: [frag.identifier])
      expect(tag.content).to be(true)
    end
  end

  describe "#form_field" do
    it "renders the field" do
      tag = described_class.new(context: page, params: ["test"])
      output = tag.form_field("object_name", view, 0, &:itself)

      expect(output).to have_tag("div") do
        with_tag "input", with: { type: "hidden", name: "object_name[fragments_attributes][0][boolean]", value: "0" }
        with_tag "input", with: { type: "checkbox", name: "object_name[fragments_attributes][0][boolean]", value: "1" }
      end
    end
  end
end
