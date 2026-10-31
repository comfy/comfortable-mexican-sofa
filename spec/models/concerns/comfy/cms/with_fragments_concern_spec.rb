# frozen_string_literal: true

require "rails_helper"

RSpec.describe Comfy::Cms::WithFragmentsConcern do
  let(:page) { comfy_cms_pages(:default) }

  describe "#fragments_attributes" do
    it "returns list of fragment attributes" do
      expected = [
        {
          identifier:  "boolean",
          tag:         "checkbox",
          content:     nil,
          datetime:    nil,
          boolean:     true,
          attachments: []
        }, {
          identifier:  "file",
          tag:         "file",
          content:     nil,
          datetime:    nil,
          boolean:     false,
          attachments: [comfy_cms_fragments(:file).attachments.first.signed_id]
        }, {
          identifier:  "datetime",
          tag:         "datetime",
          content:     nil,
          datetime:    comfy_cms_fragments(:datetime).datetime,
          boolean:     false,
          attachments: []
        }, {
          identifier:  "content",
          tag:         "text",
          content:     "fragment-content {{cms:snippet default}}",
          datetime:    nil,
          boolean:     false,
          attachments: []
        }
      ]
      expect(page.fragments_attributes).to match_array(expected)
    end
  end

  describe "#fragments_attributes=" do
    it "sets attributes for a new fragment" do
      page.fragments_attributes = [
        {
          tag:        "text",
          identifier: "new",
          content:    "new content"
        }
      ]
      expected = {
        attachments: [],
        boolean:     false,
        content:     "new content",
        datetime:    nil,
        identifier:  "new",
        tag:         "text"
      }
      expect(page.fragments_attributes).to include(expected)
      expect(page.fragments_attributes_changed).to be(true)
    end

    it "updates existing fragment" do
      page.fragments_attributes = [
        {
          identifier: "content",
          content:    "updated content"
        }
      ]
      expected = {
        attachments: [],
        boolean:     false,
        content:     "updated content",
        datetime:    nil,
        identifier:  "content",
        tag:         "text"
      }
      expect(page.fragments_attributes).to include(expected)
      expect(page.fragments_attributes_changed).to be(true)
    end

    it "does not show anything for new attachments as signed_id does not exist yet" do
      page.fragments_attributes = [
        {
          tag:         "files",
          identifier:  "new",
          attachments: [fixture_file_upload("data.zip", "application/zip")]
        }
      ]
      expected = {
        attachments: [nil],
        boolean:     false,
        content:     nil,
        datetime:    nil,
        identifier:  "new",
        tag:         "files"
      }
      expect(page.fragments_attributes).to include(expected)
      expect(page.fragments_attributes_changed).to be(true)
    end

    it "does not set dirty flag if there are no changes" do
      frag = comfy_cms_fragments(:default)

      page.fragments_attributes = [
        {
          identifier: frag.identifier,
          content:    frag.content
        }
      ]
      expect(page.fragments_attributes_changed).to be(false)
    end
  end

  describe "#fragments_attributes_was" do
    it "tracks changed content" do
      page.fragments_attributes = [
        {
          identifier: "content",
          content:    "updated content"
        }
      ]
      expected = {
        attachments: [],
        boolean:     false,
        content:     "fragment-content {{cms:snippet default}}",
        datetime:    nil,
        identifier:  "content",
        tag:         "text"
      }
      expect(page.fragments_attributes_was).to include(expected)
    end
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
