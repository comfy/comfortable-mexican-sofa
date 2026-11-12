# frozen_string_literal: true

require "rails_helper"

RSpec.describe Comfy::Cms::Page do
  let(:site)   { comfy_cms_sites(:default) }
  let(:layout) { comfy_cms_layouts(:default) }
  let(:page)   { comfy_cms_pages(:default) }

  it_behaves_like "model with valid fixture data"
  it_behaves_like "model with presence validations", :label, :layout, :site, :slug

  describe "callbacks" do
    describe "#assign_parent" do
      it "assigns parent page if not provided" do

      end

      it "does nothing if page is root" do

      end

      it "does nothing if parent is already specified" do

      end
    end
  end

  describe "validations" do

  end

  describe ".create" do
    it "creates page with text fragment" do
      new_page = site.pages.create(
        parent:               page,
        layout:               layout,
        slug:                 "test-page",
        fragments_attributes: [
          {
            identifier: "test",
            tag:        "text",
            content:    "test-content"
          }
        ]
      )
      expect(new_page).to be_persisted
      expect(new_page.position).to eq(2)
      expect(new_page.fragments.count).to eq(1)
      expect(new_page.fragments.first.content).to eq("test-content")
    end

    it "creates page with attachments fragment" do
      new_page = site.pages.create(
        parent:               page,
        layout:               layout,
        slug:                 "test-page",
        fragments_attributes: [
          {
            identifier: "test",
            tag:        "files",
            files:      [
              fixture_file_upload("image.jpg"),
              fixture_file_upload("document.pdf")
            ]
          }
        ]
      )
      expect(new_page).to be_persisted
      expect(new_page.fragments.count).to eq(1)
      expect(new_page.fragments.first.attachments.count).to eq(2)
    end

    it "creates page with boolean fragment" do
      new_page = site.pages.create(
        parent:               page,
        layout:               layout,
        slug:                 "test-page",
        fragments_attributes: [
          {
            identifier: "test",
            tag:        "boolean",
            boolean:    "1"
          }
        ]
      )
      expect(new_page).to be_persisted
      expect(new_page.fragments.count).to eq(1)
      expect(new_page.fragments.first.boolean).to be(true)
    end

    it "creates page with datetime fragment" do
      datetime_string = "1981-10-04 12:34:56"
      datetime        = DateTime.parse(datetime_string)

      new_page = site.pages.create(
        parent:               page,
        layout:               layout,
        slug:                 "test-page",
        fragments_attributes: [
          {
            identifier: "test",
            tag:        "boolean",
            datetime:   datetime_string
          }
        ]
      )
      expect(new_page).to be_persisted
      expect(new_page.fragments.count).to eq(1)
      expect(new_page.fragments.first.datetime).to eq(datetime)
    end
  end

  describe "#update" do
    it "updates page with text fragment" do
      frag = comfy_cms_fragments(:default)

      expect do
        page.update!(
          fragments_attributes: [
            {
              identifier: frag.identifier,
              content:    "updated content"
            }
          ]
        )
      end.not_to change(Comfy::Cms::Fragment, :count)

      expect(frag.reload.content).to eq("updated content")
    end

    it "updates page with new attachments" do
      frag = comfy_cms_fragments(:file)

      expect do
        page.update!(
          fragments_attributes: [
            {
              identifier: frag.identifier,
              files:      [fixture_file_upload("document.pdf")]
            }
          ]
        )
      end.to change(frag.reload.attachments, :count).by(1)

      expect(frag.reload.attachments.last.filename.to_s).to eq("document.pdf")
    end

    it "updates page with attachment removal" do
      frag = comfy_cms_fragments(:file)

      expect do
        page.update!(
          fragments_attributes: [
            {
              identifier:       frag.identifier,
              file_ids_destroy: [frag.attachments.first.id]
            }
          ]
        )
      end.to change(frag.reload.attachments, :count).by(-1)
    end

    it "updates page with boolean fragment" do
      frag = comfy_cms_fragments(:boolean)

      page.update!(
        fragments_attributes: [
          {
            identifier: frag.identifier,
            boolean:    "0"
          }
        ]
      )
      expect(frag.reload.boolean).to be(false)
    end

    it "updates page with datetime fragment" do
      frag        = comfy_cms_fragments(:datetime)
      date_string = "2020-01-01"
      date        = DateTime.parse(date_string)

      page.update!(
        fragments_attributes: [
          {
            identifier: frag.identifier,
            datetime:   date_string
          }
        ]
      )
      expect(frag.reload.datetime).to eq(date)
    end
  end
end
