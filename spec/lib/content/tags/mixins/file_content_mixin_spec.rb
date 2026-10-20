# frozen_string_literal: true

require "rails_helper"

RSpec.describe ComfortableMexicanSofa::Content::FileContentMixin do
  include ActionView::TestCase::Behavior

  let(:page)      { comfy_cms_pages(:default) }
  let(:frag)      { comfy_cms_fragments(:file) }
  let(:tag_class) { ComfortableMexicanSofa::Content::FileTag }

  describe "#content" do
    it "returns nothing if there's no attached file" do
      tag = tag_class.new(context: page, params: ["test"])
      expect(tag.send(:file)).to be_nil
      expect(tag.content).to eq("")
    end

    it "returns url string" do
      tag = tag_class.new(context: page, params: [frag.identifier])
      expect(tag.send(:file)).to be_a(ActiveStorage::Attachment)
      expect(tag.content).to start_with("/rails/active_storage/blobs/redirect/").and end_with("/image.jpg")
    end

    it "returns link tag" do
      tag = tag_class.new(context: page, params: [frag.identifier, "as" => "link"])
      expect(tag.content).to have_tag(:a, with: { target: "_blank" }, text: "image.jpg")
    end

    it "returns link tag with class and label" do
      options = { "as" => "link", "class" => "custom", "label" => "label" }
      tag = tag_class.new(context: page, params: [frag.identifier, options])
      expect(tag.content).to have_tag(:a, with: { target: "_blank", class: "custom" }, text: "label")
    end

    it "returns image tag" do
      tag = tag_class.new(context: page, params: [frag.identifier, "as" => "image"])
      expect(tag.content).to have_tag(:img, with: { alt: "image.jpg" })
    end

    it "returns image tag with class and label" do
      options = { "as" => "image", "class" => "custom", "label" => "label" }
      tag = tag_class.new(context: page, params: [frag.identifier, options])
      expect(tag.content).to have_tag(:img, with: { class: "custom", alt: "label" })
    end

    it "returns variant url" do
      options = { "resize_to_limit" => "50x100" }
      tag = tag_class.new(context: page, params: [frag.identifier, options])
      expect(tag.content).to start_with("/rails/active_storage/representations/redirect/").and end_with("/image.jpg")
    end
  end

  describe "#variant_options" do
    it "converts options into image_processing options" do
      tag = tag_class.new(context: page, params: [frag.identifier, "resize_to_fill" => "100x50"])
      expect(tag.variant_options).to eq(resize_to_fill: [100, 50])
    end

    it "only handles one variant option (slice controls the order)" do
      params = { "resize_and_pad" => "50x25", "resize_to_fill" => "100x50" }
      tag = tag_class.new(context: page, params: [frag.identifier, params])
      expect(tag.variant_options).to eq(resize_to_fill: [100, 50])
    end

    it "ignores malformed option" do
      tag = tag_class.new(context: page, params: [frag.identifier, "resize_to_fill" => "foox50"])
      expect(tag.variant_options).to eq({})
    end

    it "handles spaces" do
      tag = tag_class.new(context: page, params: [frag.identifier, "resize_and_pad" => "100 x 50"])
      expect(tag.variant_options).to eq(resize_and_pad: [100, 50])
    end

    it "limits image dimensions" do
      tag = tag_class.new(context: page, params: [frag.identifier, "resize_to_fit" => "9999999 x 999999"])
      expect(tag.variant_options).to eq(resize_to_fit: [2500, 2500])
    end
  end
end
