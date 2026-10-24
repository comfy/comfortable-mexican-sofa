# frozen_string_literal: true

require "rails_helper"

RSpec.describe ComfortableMexicanSofa::Content::Tag do
  let(:page) { comfy_cms_pages(:default) }

  let(:tag_class) do
    Class.new(ComfortableMexicanSofa::Content::Tag) do
      def content
        "test tag content"
      end
    end
  end

  let(:nesting_tag_class) do
    Class.new(ComfortableMexicanSofa::Content::Tag) do
      def content
        "nesting {{cms:test}} content"
      end

      def render
        "rendering: #{content}"
      end
    end
  end

  before do
    ComfortableMexicanSofa::Content::Renderer.register_tag(:test, tag_class)
    ComfortableMexicanSofa::Content::Renderer.register_tag(:test_nesting, nesting_tag_class)
  end

  after do
    ComfortableMexicanSofa::Content::Renderer.tags.delete("test")
    ComfortableMexicanSofa::Content::Renderer.tags.delete("test_nesting")
  end

  describe ".new" do
    it "initializes tag" do
      tag = tag_class.new(
        context: page,
        params:  ["param_a", { "key" => "value" }],
        source:  "source"
      )
      expect(tag.context).to eq(page)
      expect(tag.params).to eq(["param_a", { "key" => "value" }])
      expect(tag.source).to eq("source")
    end
  end

  describe "#allow_erb?" do
    it "returns default but some tags can enable it" do
      expect(tag_class.new(context: nil).allow_erb?).to be(false)
    end
  end

  describe "#nodes" do
    it "returns nodes from the simple tag" do
      tag = tag_class.new(context: nil, params: [], source: "")
      expect(tag.nodes).to eq(["test tag content"])
    end

    it "returns nodes from the nesting tag" do
      tag = nesting_tag_class.new(context: nil, params: [], source: "")

      expect(tag.nodes[0]).to eq("nesting ")
      expect(tag.nodes[1]).to be_a(tag_class)
      expect(tag.nodes[2]).to eq(" content")
    end
  end

  describe "#content" do
    it "returns tag's content" do
      tag = nesting_tag_class.new(context: nil, params: [], source: "")
      expect(tag.content).to eq("nesting {{cms:test}} content")
    end
  end

  describe "#render" do
    it "renders content" do
      tag = nesting_tag_class.new(context: nil, params: [], source: "")
      expect(tag.render).to eq("rendering: nesting {{cms:test}} content")
    end
  end
end
