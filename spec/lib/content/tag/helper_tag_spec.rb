# frozen_string_literal: true

require "rails_helper"

RSpec.describe ComfortableMexicanSofa::Content::Tag::HelperTag do
  it "is registered with renderer" do
    expect(ComfortableMexicanSofa::Content::Renderer.tags["helper"]).to eq(described_class)
  end

  describe ".new" do
    it "initializes tag" do
      tag = described_class.new(context: nil, params: ["test_helper"])
      expect(tag.method_name).to eq("test_helper")
    end

    it "initializes tag with options" do
      tag = described_class.new(context: nil, params: ["test_helper", "foo", "bar", { "eggs" => "ham" }])
      expect(tag.method_name).to eq("test_helper")
      expect(tag.params).to eq(%w[foo bar])
      expect(tag.options).to eq({ "eggs" => "ham" })
    end

    it "throws error if identifier is not provided" do
      expect do
        described_class.new(context: nil, params: [], source: "{{cms:helper}}")
      end.to raise_error(described_class::Error, "Missing method name for helper tag: {{cms:helper}}")
    end
  end

  describe "#content" do
    it "returns nothing if method is not whitelisted" do
      expect(ComfortableMexicanSofa.config.allowed_helpers).to be_blank
      tag = described_class.new(context: nil, params: ["test_helper", "foo", "bar", { "eggs" => "ham" }])
      expect(tag.content).to eq("")
    end

    context "with allowed helper" do
      before do
        ComfortableMexicanSofa.config.allowed_helpers = [:test_helper]
      end

      it "returns erb code" do
        tag = described_class.new(context: nil, params: ["test_helper"])
        expect(tag.content).to eq("<%= test_helper() %>")
      end

      it "returns erb code with params" do
        tag = described_class.new(context: nil, params: %w[test_helper foo bar])
        expect(tag.content).to eq('<%= test_helper("foo","bar") %>')
      end

      it "returns erb code with options" do
        tag = described_class.new(context: nil, params: ["test_helper", { "foo" => "bar", "eggs" => "ham" }])
        expect(tag.content).to eq('<%= test_helper({"foo" => "bar", "eggs" => "ham"}) %>')
      end

      it "returns erb code with all params and options" do
        params = ["test_helper", "foo", "bar", { "foo" => "bar", "eggs" => "ham" }]
        tag = described_class.new(context: nil, params: params)
        expect(tag.content).to eq('<%= test_helper("foo","bar",{"foo" => "bar", "eggs" => "ham"}) %>')
      end

      it "escapes string interpolation" do
        tag = described_class.new(context: nil, params: ["test_helper", "foo\#{:bar}", { "key" => "va\#{:l}ue" }])
        expect(tag.content).to eq('<%= test_helper("foo\\#{:bar}",{"key" => "va\\#{:l}ue"}) %>')
      end
    end
  end

  describe "allow_erb?" do
    it "returns true" do
      tag = described_class.new(context: nil, params: ["test_helper"])
      expect(tag.allow_erb?).to be(true)
    end
  end
end
