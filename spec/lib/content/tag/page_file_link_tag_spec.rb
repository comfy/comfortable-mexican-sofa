# frozen_string_literal: true

require "rails_helper"

RSpec.describe ComfortableMexicanSofa::Content::Tag::PageFileLinkTag do
  include ActionView::TestCase::Behavior

  let(:page) { comfy_cms_pages(:default) }
  let(:frag) { comfy_cms_fragments(:file) }

  it "is registered with renderer" do
    expect(ComfortableMexicanSofa::Content::Renderer.tags["page_file_link"]).to eq(described_class)
  end

  describe ".new" do
    it "initializes tag" do
      tag = described_class.new(context: page, params: ["test"])
      expect(tag.identifier).to eq("test")
      expect(tag.as).to eq("url")
      expect(tag.variant_options).to eq({})
    end

    it "errors out if identifier is not passed in" do
      expect do
        described_class.new(context: page, params: [], source: "{{cms:page_file_link}}")
      end.to raise_error(described_class::Error, "Missing identifier for tag: {{cms:page_file_link}}")
    end
  end

  describe "#content" do
    it "renders out file" do
      tag = described_class.new(context: page, params: [frag.identifier])
      expect(tag.content).to start_with("/rails/active_storage/blobs/redirect/").and end_with("/image.jpg")
    end

    it "does nothing if fragment cannot be found" do
      tag = described_class.new(context: page, params: ["invalid"])
      expect(tag.content).to eq("")
    end
  end
end
