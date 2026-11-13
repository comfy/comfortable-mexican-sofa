# frozen_string_literal: true

require "rails_helper"

RSpec.describe ComfortableMexicanSofa::Content::Tag::SiteFileLinkTag do
  include ActionView::TestCase::Behavior

  let(:page) { comfy_cms_pages(:default) }
  let(:file) { comfy_cms_files(:default) }

  it "is registered with renderer" do
    expect(ComfortableMexicanSofa::Content::Renderer.tags["site_file_link"]).to eq(described_class)
  end

  describe ".new" do
    it "initializes tag" do
      tag = described_class.new(context: page, params: ["test.png"])
      expect(tag.filename).to eq("test.png")
      expect(tag.as).to eq("url")
      expect(tag.variant_options).to eq({})
    end

    it "errors out if filename is not passed in" do
      expect do
        described_class.new(context: page, params: [], source: "{{cms:site_file_link}}")
      end.to raise_error(described_class::Error, "Missing filename for tag: {{cms:site_file_link}}")
    end
  end

  describe "#content" do
    it "renders out file" do
      tag = described_class.new(context: page, params: [file.attachment.filename])
      expect(tag.content).to start_with("/rails/active_storage/blobs/redirect/").and end_with("/image.gif")
    end

    it "does nothing if file cannot be found" do
      tag = described_class.new(context: page, params: ["invalid"])
      expect(tag.content).to eq("")
    end
  end
end
