# frozen_string_literal: true

require "rails_helper"

RSpec.describe Comfy::Cms::Fragment do
  let(:page) { comfy_cms_pages(:default) }
  let(:frag) { comfy_cms_fragments(:file) }

  it_behaves_like "model with valid fixture data"
  it_behaves_like "model with presence validations", :identifier, :record

  describe "relationships" do
    it "touches record on fragment update" do
      old_timestamp = 2.days.ago
      page.update_column(:updated_at, old_timestamp)
      page.fragments.first.update!(content: "Updated")
      expect(page.reload.updated_at).not_to eq(old_timestamp)
    end
  end

  describe ".create" do
    it "creates record" do
      frag = page.fragments.create(
        identifier: "test-frag",
        content:    "test content"
      )
      expect(frag).to be_persisted
      expect(frag.tag).to eq("text")
    end

    it "creates record with files" do
      frag = page.fragments.create(
        identifier: "test-frag",
        files:      [fixture_file_upload("document.pdf", "application/pdf")]
      )
      expect(frag).to be_persisted
      expect(frag.attachments).to be_present
    end
  end

  describe "#files=" do
    it "assigns new files without nuking existing ones" do
      frag.update!(files: [fixture_file_upload("document.pdf", "application/pdf")])

      expect(frag.attachments.count).to eq(2)
      expect(frag.attachments.map(&:filename)).to include("document.pdf")
    end

    it "does nothing if nothing is passed in" do
      frag.update!(files: [])
      expect(frag.attachments).to be_present
    end
  end

  describe "#file_ids_destroy=" do
    it "removes attachments" do
      frag.update!(file_ids_destroy: frag.attachments.pluck(:id))
      expect(frag.attachments).to be_blank
    end

    it "does nothing if nothing is passed in" do
      frag.update!(file_ids_destroy: [])
      expect(frag.attachments).to be_present
    end
  end
end
