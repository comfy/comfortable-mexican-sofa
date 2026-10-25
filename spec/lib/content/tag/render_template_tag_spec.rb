# frozen_string_literal: true

require "rails_helper"

RSpec.describe ComfortableMexicanSofa::Content::Tag::RenderTemplateTag do
  it "is registered with renderer" do
    expect(ComfortableMexicanSofa::Content::Renderer.tags["render_template"]).to eq(described_class)
  end

  describe ".new" do
    it "initializes tag" do
      tag = described_class.new(context: nil, params: ["test/path"])
      expect(tag.path).to eq("test/path")
    end

    it "throws error if identifier is not provided" do
      expect do
        described_class.new(context: nil, params: [], source: "{{cms:render_template}}")
      end.to raise_error(described_class::Error, "Missing path for render template tag: {{cms:render_template}}")
    end
  end

  describe "#content" do
    it "outputs nothing unless it's in the whitelist" do
      tag = described_class.new(context: nil, params: ["not_allowed/path"])
      expect(tag.content).to eq("")
    end

    context "with allowed template" do
      before do
        ComfortableMexicanSofa.config.allowed_templates = ["test/template"]
      end

      it "outputs erb" do
        tag = described_class.new(context: nil, params: ["test/template"])
        expect(tag.content).to eq("<%= render template: \"test/template\" %>")
      end
    end
  end

  describe "allow_erb?" do
    it "returns true" do
      tag = described_class.new(context: nil, params: ["test/path"])
      expect(tag.allow_erb?).to be(true)
    end
  end
end
