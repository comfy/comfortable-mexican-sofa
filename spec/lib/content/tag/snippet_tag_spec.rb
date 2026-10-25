# frozen_string_literal: true

require "rails_helper"

RSpec.describe ComfortableMexicanSofa::Content::Tag::SnippetTag do
  include ActionView::TestCase::Behavior

  let(:page)    { comfy_cms_pages(:default) }
  let(:snippet) { comfy_cms_snippets(:default) }

  it "is registered with renderer" do
    expect(ComfortableMexicanSofa::Content::Renderer.tags["snippet"]).to eq(described_class)
  end

  describe ".new" do
    it "initializes tag" do
      tag = described_class.new(context: page, params: ["test"])
      expect(tag.identifier).to eq("test")
    end

    it "throws error if identifier is not provided" do
      expect do
        described_class.new(context: page, params: [], source: "{{cms:snippet}}")
      end.to raise_error(described_class::Error, "Missing identifier for snippet tag: {{cms:snippet}}")
    end
  end

  describe "#content" do
    it "outputs snippet content" do
      tag = described_class.new(context: page, params: [snippet.identifier])
      expect(tag.content).to eq("snippet content")
    end

    it "outputs nothing if snippet not found" do
      tag = described_class.new(context: page, params: ["invalid"])
      expect(tag.content).to eq("")
    end
  end
end
