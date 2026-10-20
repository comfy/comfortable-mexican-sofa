# frozen_string_literal: true

require "rails_helper"

RSpec.describe ComfortableMexicanSofa::Content::FileTag do
  include ActionView::TestCase::Behavior

  let(:page) { comfy_cms_pages(:default) }
  let(:frag) { comfy_cms_fragments(:file) }

  it "is registered with renderer" do
    expect(ComfortableMexicanSofa::Content::Renderer.tags["file"]).to eq(described_class)
  end

  describe ".new" do
    it "initializes tag" do
      tag = described_class.new(context: page, params: ["test"])
      expect(tag.identifier).to eq("test")
      expect(tag.as).to eq("url")
      expect(tag.variant_options).to eq({})
    end

    it "initializes with options" do
      tag = described_class.new(context: page, params: ["test", "as" => "image", "resize_to_fill" => "50x50"])
      expect(tag.identifier).to eq("test")
      expect(tag.as).to eq("image")
      expect(tag.variant_options).to eq(resize_to_fill: [50, 50])
    end
  end

  describe "#variant_options" do
    it "converts options into image_processing options" do
      tag = described_class.new(context: page, params: [frag.identifier, "resize_to_fill" => "100x50"])
      expect(tag.variant_options).to eq(resize_to_fill: [100, 50])
    end

    it "only handles one variant option (slice controls the order)" do
      params = { "resize_and_pad" => "50x25", "resize_to_fill" => "100x50" }
      tag = described_class.new(context: page, params: [frag.identifier, params])
      expect(tag.variant_options).to eq(resize_to_fill: [100, 50])
    end

    it "ignores malformed option" do
      tag = described_class.new(context: page, params: [frag.identifier, "resize_to_fill" => "foox50"])
      expect(tag.variant_options).to eq({})
    end

    it "handles spaces" do
      tag = described_class.new(context: page, params: [frag.identifier, "resize_and_pad" => "100 x 50"])
      expect(tag.variant_options).to eq(resize_and_pad: [100, 50])
    end
  end

  describe "#form_field" do
    it "renders the field" do
      tag = described_class.new(context: page, params: ["test"])
      output = tag.form_field("object_name", view, 0, &:itself)
      expect(output).to have_tag("input", with: {
        type: "file",
        name: "object_name[fragments_attributes][0][files]",
        id:   "fragment-test"
      })
    end

    it "renders field with attached file" do
      skip "todo when view components are in"
    end
  end

end
