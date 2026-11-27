# frozen_string_literal: true

require "rails_helper"

RSpec.describe Comfy::Cms::Snippet do
  let(:site)    { comfy_cms_sites(:default) }
  let(:snippet) { comfy_cms_snippets(:default) }

  it_behaves_like "model with valid fixture data"
  it_behaves_like "model with presence validations", :site, :identifier, :label

  describe "callbacks" do
    describe "#assign_label" do
      it "assigns label" do
        snippet = described_class.new(identifier: "test-snippet")
        snippet.validate
        expect(snippet.label).to eq("Test Snippet")
      end

      it "does nothing if identifer is blank" do
        snippet = described_class.new(identifier: "")
        snippet.validate
        expect(snippet.label).to be_blank
      end

      it "does nothing if label is set" do
        snippet = described_class.new(identifier: "test-snippet", label: "Existing")
        snippet.validate
        expect(snippet.label).to eq("Existing")
      end
    end

    describe "#assign_position" do
      it "sets position after last sibling" do
        sibling_snippet = site.snippets.create!(identifier: "sibling_snippet")
        expect(sibling_snippet.position).to eq(1)
      end

      it "leaves position value alone if explicitly set" do
        sibling_snippet = site.layouts.create!(identifier: "sibling_snippet", position: 99)
        expect(sibling_snippet.position).to eq(99)
      end
    end

    describe "#clear_page_content_cache" do
      let(:page) { comfy_cms_pages(:default) }

      it "clears all page caches on update" do
        expect(page.content_cache).to eq("fragment-content snippet-content")
        snippet.update!(content: "Updated")
        expect(page.reload.content_cache).to eq("fragment-content Updated")
      end

      it "clears all page caches on destroy" do
        snippet.destroy
        expect(page.reload.content_cache).to eq("fragment-content ")
      end
    end
  end

  describe ".create" do
    it "creates record" do
      layout = site.snippets.create(
        label:      "New Snippet",
        identifier: "new-snippet",
        content:    "snippet content"
      )
      expect(layout.label).to eq("New Snippet")
      expect(layout.identifier).to eq("new-snippet")
      expect(layout.content).to eq("snippet content")
      expect(layout.position).to eq(1)
    end
  end
end
