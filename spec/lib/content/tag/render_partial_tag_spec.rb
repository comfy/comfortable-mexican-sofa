# frozen_string_literal: true

require "rails_helper"

RSpec.describe ComfortableMexicanSofa::Content::Tag::RenderPartialTag do
  it "is registered with renderer" do
    expect(ComfortableMexicanSofa::Content::Renderer.tags["render_partial"]).to eq(described_class)
  end

  describe ".new" do
    it "initializes tag" do
      tag = described_class.new(context: nil, params: ["test/path"])
      expect(tag.path).to eq("test/path")
      expect(tag.options).to eq({})
    end

    it "initializes tag with partial locals" do
      tag = described_class.new(context: nil, params: ["test/path", { "foo" => "bar", "eggs" => "ham" }])
      expect(tag.path).to eq("test/path")
      expect(tag.options).to eq({ "eggs" => "ham", "foo" => "bar" })
    end

    it "throws error if identifier is not provided" do
      expect do
        described_class.new(context: nil, params: [], source: "{{cms:render_partial}}")
      end.to raise_error(described_class::Error, "Missing path for render partial tag: {{cms:render_partial}}")
    end
  end

  describe "#content" do
    it "outputs nothing if partial not allowed" do
      expect(ComfortableMexicanSofa.config.allowed_partials).to be_blank
      tag = described_class.new(context: nil, params: ["test/path"])
      expect(tag.content).to eq("")
    end

    context "with allowed partial" do
      before do
        ComfortableMexicanSofa.config.allowed_partials = ["test/path"]
      end

      it "outputs erb" do
        tag = described_class.new(context: nil, params: ["test/path", { "foo" => "bar" }])
        expect(tag.content).to eq('<%= render partial: "test/path", locals: {"foo" => "bar"} %>')
      end

      it "escapes string interpolations" do
        tag = described_class.new(context: nil, params: ["test/path", { "key" => "va\#{:l}ue" }])
        expect(tag.content).to eq('<%= render partial: "test/path", locals: {"key" => "va\\#{:l}ue"} %>')
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
