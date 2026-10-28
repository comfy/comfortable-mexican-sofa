# frozen_string_literal: true

require "rails_helper"

RSpec.describe ComfortableMexicanSofa::Content::FragmentTag do
  let(:page) { comfy_cms_pages(:default) }

  describe ".new" do
    it "initializes object" do
      tag = described_class.new(context: page, params: ["foo"])
      expect(tag.context).to eq(page)
      expect(tag.identifier).to eq("foo")
      expect(tag.renderable).to be(true)
      expect(tag.namespace).to eq("default")
    end

    it "initializes object with params" do
      tag = described_class.new(
        context: page,
        params:  ["foo", { "render" => "false", "namespace" => "test" }]
      )
      expect(tag.renderable).to be(false)
      expect(tag.namespace).to eq("test")
    end

    it "errors out when identifier is not provided" do
      expect do
        described_class.new(context: page, source: "{{cms:foo-tag}}")
      end.to raise_error(described_class::Error, "Missing identifier for fragment tag: {{cms:foo-tag}}")
    end
  end

  describe "#fragment" do
    it "returns existing fragment record" do
      tag = described_class.new(context: page, params: ["content"])
      expect(tag.fragment).to eq(comfy_cms_fragments(:default))
    end

    it "returns new fragment record if there aren't any" do
      tag = described_class.new(context: page, params: ["new"])
      expect(tag.fragment).to be_a(Comfy::Cms::Fragment)
      expect(tag.fragment).to be_new_record
      expect(tag.fragment.identifier).to eq("new")
    end
  end

  describe "#content" do
    it "returns content for existing fragment" do
      tag = described_class.new(context: page, params: ["content"])
      expect(tag.content).to eq("fragment content {{cms:snippet default}}")
    end

    it "returns content for new fragment" do
      tag = described_class.new(context: page, params: ["new"])
      expect(tag.content).to be_nil
    end
  end

  describe "#render" do
    it "outputs tag content" do
      tag = described_class.new(context: page, params: ["content"])
      expect(tag.render).to eq("fragment content {{cms:snippet default}}")
    end

    it "outputs nothing if not renderable" do
      tag = described_class.new(context: page, params: ["content", { "render" => "false" }])
      expect(tag.render).to eq("")
    end
  end

  describe "#form_field" do
    it "errors out as base class does not implement this method" do
      expect do
        tag = described_class.new(context: page, params: ["content"])
        tag.form_field
      end.to raise_error(described_class::Error, "Form field rendering not implemented for this Tag class")
    end
  end

  describe "#form_field_id" do
    it "returns string that is used in form construction" do
      tag = described_class.new(context: page, params: ["content"])
      expect(tag.form_field_id).to eq("fragment-content")
    end
  end
end
