# frozen_string_literal: true

require "rails_helper"

RSpec.describe ComfortableMexicanSofa::Content::Tag::LayoutAssetTag do
  include ActionView::TestCase::Behavior

  let(:page)   { comfy_cms_pages(:default) }
  let(:layout) { comfy_cms_layouts(:default) }

  it "is registered with renderer" do
    expect(ComfortableMexicanSofa::Content::Renderer.tags["layout_asset"]).to eq(described_class)
  end

  describe ".new" do
    it "initializes tag" do
      tag = described_class.new(context: page, params: ["test"])
      expect(tag.identifier).to eq("test")
      expect(tag.type).to eq("css")
      expect(tag.as).to eq("url")
    end

    it "throws error if identifier is not provided" do
      expect do
        described_class.new(context: page, params: [], source: "{{cms:layout_asset}}")
      end.to raise_error(described_class::Error, "Missing layout identifier for asset tag: {{cms:layout_asset}}")
    end
  end

  describe "#content" do
    it "outputs nothing if layout not found" do
      tag = described_class.new(context: page, params: ["invalid"])
      expect(tag.content).to eq("")
    end

    it "outputs url for css" do
      tag = described_class.new(context: page, params: [layout.identifier])
      path = "/cms-css/#{page.site_id}/#{layout.identifier}/#{layout.cache_buster}.css"
      expect(tag.content).to eq(path)
    end

    it "outputs stylesheet tag" do
      tag = described_class.new(context: page, params: [layout.identifier, { "type" => "css", "as" => "tag" }])
      path = "/cms-css/#{page.site_id}/#{layout.identifier}/#{layout.cache_buster}.css"
      html = "<link rel=\"stylesheet\" href=\"#{path}\" media=\"screen\" />"
      expect(tag.content).to eq(html)
    end

    it "outputs url for js" do
      tag = described_class.new(context: page, params: [layout.identifier, { "type" => "js" }])
      path = "/cms-js/#{page.site_id}/#{layout.identifier}/#{layout.cache_buster}.js"
      expect(tag.content).to eq(path)
    end

    it "outputs script tag" do
      tag = described_class.new(context: page, params: [layout.identifier, { "type" => "js", "as" => "tag" }])
      path = "/cms-js/#{page.site_id}/#{layout.identifier}/#{layout.cache_buster}.js"
      html = "<script src=\"#{path}\"></script>"
      expect(tag.content).to eq(html)
    end
  end
end
