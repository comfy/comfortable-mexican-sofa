# frozen_string_literal: true

require "rails_helper"

RSpec.describe Comfy::Cms::WithFragmentsConcern do
  let(:page) { comfy_cms_pages(:default) }

  describe "#fragments_attributes=" do

  end

  describe "#fragments_attributes" do

  end

  describe "#fragments_attributes_was" do

  end

  describe "#fragment_nodes" do
    it "returns list of fragment tag nodes" do
      content = "a {{cms:text a}} b {{cms:snippet b}} c {{cms:text c}}"
      page.layout.update_column(:content, content)
      nodes = page.fragment_nodes
      expect(nodes.count).to eq(2)
      expect(nodes[0].identifier).to eq("a")
      expect(nodes[1].identifier).to eq("c")
    end

    it "ignores duplicate nodes" do
      content = "{{cms:wysiwyg test}} {{cms:markdown test}}"
      page.layout.update_column(:content, content)
      nodes = page.fragment_nodes
      expect(nodes.count).to eq(1)
      expect(nodes[0].identifier).to eq("test")
      expect(nodes[0].class).to eq(ComfortableMexicanSofa::Content::Tag::WysiwygTag)
    end

    it "returns nothing if layout was disconnected" do
      page.update_column(:layout_id, nil)
      expect(page.fragment_nodes).to eq([])
    end
  end

  describe "#render" do
    it "renders content" do
      expect(page.render).to eq("fragment-content snippet-content")
    end
  end

  describe "#content_cache" do
    it "outputs cached content" do
      page.update_column(:content_cache, "cached")
      expect(page.content_cache).to eq("cached")
    end

    it "populates content cache if it was nullified" do
      expect(page[:content_cache]).to be_nil
      expect(page.content_cache).to eq("fragment-content snippet-content")
    end

    it "returns value for non-persisted records" do
      page = Comfy::Cms::Page.new
      expect(page.content_cache).to eq("")
    end

    it "regenerates cache on save (via before_save :clear_content_cache)" do
      page.update_column(:content_cache, "cached")
      expect(page.content_cache).to eq("cached")
      page.save!

      new_cache = "fragment-content snippet-content"
      expect(page.content_cache).to eq(new_cache)
      expect(page[:content_cache]).to eq(new_cache)
    end
  end

  describe "#clear_content_cache!" do
    it "immidiately nullifies db entry" do
      page.update_column(:content_cache, "old cache")
      page.clear_content_cache!
      expect(page.read_attribute(:content_cache)).to be_nil
      expect(page.reload.read_attribute(:content_cache)).to be_nil
    end
  end

  describe "#clear_content_cache" do
    it "nullifies attribute in preparation for saving" do
      page.update_column(:content_cache, "old cache")
      page.clear_content_cache
      expect(page.read_attribute(:content_cache)).to be_nil
      expect(page.reload.read_attribute(:content_cache)).to eq("old cache")
    end
  end
end
