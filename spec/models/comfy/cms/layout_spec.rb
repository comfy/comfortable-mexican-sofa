# frozen_string_literal: true

require "rails_helper"

RSpec.describe Comfy::Cms::Layout do
  let(:site)   { comfy_cms_sites(:default) }
  let(:layout) { comfy_cms_layouts(:default) }

  it_behaves_like "model with valid fixture data"
  it_behaves_like "model with presence validations", :site, :identifier, :label

  describe "validations" do
    it "validates identifier format" do
      layout = described_class.new(identifier: "test layout")
      expect(layout).not_to be_valid
      expect(layout.errors[:identifier]).to include("is invalid")
    end

    it "validates identifier uniqueness" do
      new_layout = site.layouts.new(identifier: layout.identifier)
      expect(new_layout).not_to be_valid
      expect(new_layout.errors[:identifier]).to include("has already been taken")
    end
  end

  describe "callbacks" do
    describe "#assign_label" do
      it "assigns label" do
        layout = described_class.new(identifier: "test-layout")
        layout.validate
        expect(layout.label).to eq("Test Layout")
      end

      it "does nothing if identifer is blank" do
        layout = described_class.new(identifier: "")
        layout.validate
        expect(layout.label).to be_blank
      end

      it "does nothing if label is set" do
        layout = described_class.new(identifier: "test-layout", label: "Existing")
        layout.validate
        expect(layout.label).to eq("Existing")
      end
    end

    describe "#assign_position" do
      it "sets position after last sibling" do
        sibling_layout = site.layouts.create!(identifier: "sibling_layout")
        expect(sibling_layout.position).to eq(1)
      end

      it "leaves position value alone if explicitly set" do
        sibling_layout = site.layouts.create!(identifier: "sibling_layout", position: 99)
        expect(sibling_layout.position).to eq(99)
      end
    end
  end

  describe ".create" do
    it "creates record" do
      layout = site.layouts.create(
        label:      "New Layout",
        identifier: "new-layout",
        content:    "{{cms:text default}}",
        css:        "body{color:red}",
        js:         "alert('test')"
      )
      expect(layout.label).to eq("New Layout")
      expect(layout.identifier).to eq("new-layout")
      expect(layout.content).to eq("{{cms:text default}}")
      expect(layout.css).to eq("body{color:red}")
      expect(layout.js).to eq("alert('test')")
      expect(layout.position).to eq(1)
    end
  end

  describe ".options_for_select" do
    it "returns array of options" do
      expected = [
        ["Default Layout", layout.id],
        ["Nested Layout", comfy_cms_layouts(:nested).id],
        [". . Child Layout", comfy_cms_layouts(:child).id]
      ]
      expect(described_class.options_for_select(site)).to eq(expected)
    end
  end

  describe ".app_layouts_for_select" do
    before do
      FileUtils.touch(File.expand_path("app/views/layouts/comfy/admin/cms/nested.html.erb", Rails.root))
      FileUtils.touch(File.expand_path("app/views/layouts/comfy/_partial.html.erb", Rails.root))
      FileUtils.touch(File.expand_path("app/views/layouts/comfy/not_a_layout.erb", Rails.root))
    end

    after do
      FileUtils.rm(File.expand_path("app/views/layouts/comfy/admin/cms/nested.html.erb", Rails.root))
      FileUtils.rm(File.expand_path("app/views/layouts/comfy/_partial.html.erb", Rails.root))
      FileUtils.rm(File.expand_path("app/views/layouts/comfy/not_a_layout.erb", Rails.root))
    end

    it "returns array of options" do
      view_paths = [File.expand_path("app/views/", Rails.root)]
      expect(described_class.app_layouts_for_select(view_paths)).to eq(["comfy/admin/cms", "comfy/admin/cms/nested"])
    end
  end

  describe "#content_tokens" do
    it "parses layout content into tokens" do
      layout = described_class.new(content: "foo {{cms:text content}} bar")
      expected = [
        "foo ",
        { tag_class: "text", tag_params: "content", source: "{{cms:text content}}" },
        " bar"
      ]
      expect(layout.content_tokens).to eq(expected)
    end

    it "nests layout content into parent layout content fragment spot" do
      layout_a = described_class.new(content: "a {{cms:text content}} {{cms:text footer}} b")
      layout_b = described_class.new(content: "c {{cms:text content}} d")
      layout_b.parent = layout_a

      expected = [
        "a ",
        "c ",
        { tag_class: "text", tag_params: "content", source: "{{cms:text content}}" },
        " d",
        " ",
        { tag_class: "text", tag_params: "footer", source: "{{cms:text footer}}" },
        " b"
      ]
      expect(layout_b.content_tokens).to eq(expected)
    end

    it "uses tag format for content defined on the child" do
      layout_a = described_class.new(content: "a {{cms:markdown content}} b")
      layout_b = described_class.new(content: "c {{cms:wysiwyg content}} d")
      layout_b.parent = layout_a

      expected = [
        "a ",
        "c ",
        { tag_class: "wysiwyg", tag_params: "content", source: "{{cms:wysiwyg content}}" },
        " d",
        " b"
      ]
      expect(layout_b.content_tokens).to eq(expected)
    end

    it "only returns tokens from child layout if parent layout does not have content fragment spot" do
      layout_a = described_class.new(content: "a {{cms:snippet content}} b")
      layout_b = described_class.new(content: "c {{cms:text content}} d")
      layout_b.parent = layout_a
      expected = [
        "c ",
        { tag_class: "text", tag_params: "content", source: "{{cms:text content}}" },
        " d"
      ]
      expect(layout_b.content_tokens).to eq(expected)
    end
  end

  describe "#cache_buster" do
    it "changes value on updates" do
      expect(layout.cache_buster).to be_present
      expect do
        layout.update_column(:updated_at, 5.minutes.ago)
      end.to change(layout, :cache_buster)
    end
  end

  describe "#clear_page_content_cache" do
    let(:root_page) { comfy_cms_pages(:default) }
    let(:layout_a)  { comfy_cms_layouts(:nested) }
    let(:layout_b)  { comfy_cms_layouts(:child) }

    let(:page_a) do
      site.pages.create!(
        slug:                 "page-a",
        parent:               root_page,
        layout:               layout_a,
        fragments_attributes: [
          { identifier: "header", content: "header-content" },
          { identifier: "content", content: "content" }
        ]
      )
    end

    let(:page_b) do
      site.pages.create!(
        slug:                 "page-b",
        parent:               root_page,
        layout:               layout_b,
        fragments_attributes: [
          { identifier: "header", content: "header-content" },
          { identifier: "left_column", content: "left-column-content" },
          { identifier: "right_column", content: "left-column-content" }
        ]
      )
    end

    it "nukes content_cashes of all pages this layout was used in" do
      expect(page_a.content_cache).to eq("header-content\ncontent")
      expect(page_b.content_cache).to eq("header-content\nleft-column-content\nleft-column-content")

      # we changed text and removed {{cms:text header}} fragment
      layout_a.update!(content: "Updated {{cms:text content}}")

      expect(page_a.reload.content_cache).to eq("Updated content")
      expect(page_b.reload.content_cache).to eq("Updated left-column-content\nleft-column-content")

      # Layout is gone and there's no more content tag. All pages should be blank now
      layout_a.destroy
      expect(page_a.reload.content_cache).to eq("")
      expect(page_b.reload.content_cache).to eq("")
    end
  end
end
