# frozen_string_literal: true

require "rails_helper"

RSpec.describe Comfy::Cms::Page do
  let(:site)   { comfy_cms_sites(:default) }
  let(:layout) { comfy_cms_layouts(:default) }
  let(:page)   { comfy_cms_pages(:default) }

  it_behaves_like "model with valid fixture data"
  it_behaves_like "model with presence validations", :label, :layout, :site, :slug

  describe "callbacks" do
    describe "#assign_label" do
      it "creates label from slug" do
        page = described_class.new(slug: "test-page")
        page.validate
        expect(page.label).to eq("Test Page")
      end

      it "does nothing if slug is blank" do
        page = described_class.new
        page.validate
        expect(page.label).to be_nil
      end

      it "does nothing if label is already set" do
        page = described_class.new(slug: "test-page", label: "Custom Label")
        page.validate
        expect(page.label).to eq("Custom Label")
      end
    end

    describe "#assign_parent" do
      it "assigns parent page if not provided" do
        new_page = site.pages.new
        new_page.validate
        expect(new_page.parent).to eq(page)
      end

      it "does nothing if page is root" do
        expect(page.parent).to be_nil
        page.validate
        expect(page.parent).to be_nil
      end

      it "does nothing if parent is already specified" do
        parent_page = comfy_cms_pages(:page_b)
        page = site.pages.new(parent: parent_page)
        page.validate
        expect(page.parent).to eq(parent_page)
      end
    end

    describe "#assign_full_path" do
      it "assigns full path to the page" do
        page = site.pages.new(parent: comfy_cms_pages(:page_a), slug: "test-page")
        page.validate
        expect(page.full_path).to eq("page-a/test-page")
      end

      it "assigns blank for the root page" do
        described_class.delete_all
        page = site.pages.new
        page.validate
        expect(page.full_path).to eq("")
      end
    end

    describe "#assign_position" do
      it "sets position" do
        page = site.pages.create!(layout: layout, slug: "test")
        expect(page.position).to eq(2)
      end
    end

    describe "#sync_child_full_paths!" do
      it "parent's slug change triggers full_path updates in the tree" do
        comfy_cms_pages(:page_a).update!(slug: "new-slug")
        expect(comfy_cms_pages(:page_a_child).full_path).to eq("new-slug/page-a-child")
      end

      it "changes path when tree structure is changed" do
        comfy_cms_pages(:page_a).update!(parent: comfy_cms_pages(:page_b))
        expect(comfy_cms_pages(:page_a_child).full_path).to eq("page-b/page-a/page-a-child")
      end
    end
  end

  describe "validations" do
    describe "#slug" do
      it "ensures that slug is blank for root page" do
        expect(page.send(:root_page?)).to be(true)
        page.slug = "not-allowed"
        expect(page).not_to be_valid
        expect(page.errors[:slug]).to include("must be blank")
      end

      it "ensures that slug is populated for all other pages" do
        page = comfy_cms_pages(:page_a)
        page.slug = ""
        expect(page).not_to be_valid
        expect(page.errors[:slug]).to include("can't be blank")
      end

      it "ensures that slug is unique between siblings" do
        page = comfy_cms_pages(:page_b)
        page.slug = comfy_cms_pages(:page_a).slug
        expect(page).not_to be_valid
        expect(page.errors[:slug]).to include("has already been taken")
      end

      it "ensures that slug is correctly formatted" do
        page = comfy_cms_pages(:page_b)

        [
          "ก้",
          "ไทย-2026",
          "กรุงเทพฯ",
          "ดีๆ_มาก",
          "café-naïve.v2",
          "東京-タワー"
        ].each do |valid_slug|
          page.slug = valid_slug
          expect(page).to be_valid, valid_slug
        end

        [
          "้ก",
          "ก-้",
          "-ก้",
          "ก้-",
          "ก--ข",
          "ก/ข",
          "ก ข",
          "ก?a=1",
          "🚀-launch"
        ].each do |invalid_slug|
          page.slug = invalid_slug
          expect(page).not_to be_valid, invalid_slug
        end
      end
    end

    describe "#validate_target_page" do
      it "ensures there's no cyclical dependency" do
        redirect_to_page = comfy_cms_pages(:page_a_child)
        page.update_column(:target_page_id, redirect_to_page.id)

        redirect_to_page.target_page = page
        expect(redirect_to_page).not_to be_valid
        expect(redirect_to_page.errors[:target_page_id]).to include("invalid redirect")
      end
    end
  end

  describe ".create" do
    it "creates very first page (capturing gotcha with #root_page? method)" do
      described_class.delete_all

      page = site.pages.new(
        label:  "Homepage",
        layout: layout
      )
      expect(page.save).to be(true)
      expect(page).to be_persisted
    end

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

  describe "#url" do
    it "returns page url" do
      expect(comfy_cms_pages(:page_a_child).url).to eq("//www.example.com/page-a/page-a-child")
    end

    it "returns page relative url" do
      expect(comfy_cms_pages(:page_a_child).url(relative: true)).to eq("/page-a/page-a-child")
    end
  end
end
