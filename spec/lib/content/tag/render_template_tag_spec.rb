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
    it "outputs erb" do
      tag = described_class.new(context: nil, params: ["path/to/template"])
      expect(tag.content).to eq("<%= render template: \"path/to/template\" %>")
    end

    it "only outputs templates defined in whitelist (if there are any)" do
      ComfortableMexicanSofa.config.allowed_templates = ["allowed/path"]

      tag = described_class.new(context: nil, params: ["allowed/path"])
      expect(tag.content).to eq("<%= render template: \"allowed/path\" %>")

      tag = described_class.new(context: nil, params: ["not_allowed/path"])
      expect(tag.content).to eq("")
    end

    it "escapes string interpolations" do
      tag = described_class.new(context: nil, params: ["va\#{:l}ue"])
      expect(tag.content).to eq("<%= render template: \"va\\\#{:l}ue\" %>")
    end
  end

  describe "allow_erb?" do
    it "returns true" do
      tag = described_class.new(context: nil, params: ["test/path"])
      expect(tag.allow_erb?).to be(true)
    end
  end
end
