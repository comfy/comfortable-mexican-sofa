# frozen_string_literal: true

require "rails_helper"

RSpec.describe ComfortableMexicanSofa::Content::Tag::FileContentMixin do
  include ActionView::TestCase::Behavior

  let(:page)      { comfy_cms_pages(:default) }
  let(:frag)      { comfy_cms_fragments(:file) }
  let(:tag_class) { ComfortableMexicanSofa::Content::Tag::FilesTag }

  describe ".new" do
    it "initializes with options" do
      tag = tag_class.new(context: page, params: ["test", { "as" => "image", "resize_to_fill" => "50x50" }])
      expect(tag.identifier).to eq("test")
      expect(tag.as).to eq("image")
      expect(tag.variant_options).to eq(resize_to_fill: [50, 50])
    end
  end

  describe "#content" do
    it "returns nothing if there's no attached file" do
      tag = tag_class.new(context: page, params: ["test"])
      expect(tag.content).to eq("")
    end

    it "returns url string" do
      tag = tag_class.new(context: page, params: [frag.identifier])
      expect(tag.content).to start_with("/rails/active_storage/blobs/redirect/").and end_with("/image.jpg")
    end

    it "returns list of urls when there are multiple attachments" do
      frag.attachments.attach(fixture_file_upload("image.gif", "image/gif"))
      tag = tag_class.new(context: page, params: [frag.identifier])
      file_a, file_b = tag.content.split(", ")
      expect(file_a).to start_with("/rails/active_storage/blobs/redirect/").and end_with("/image.jpg")
      expect(file_b).to start_with("/rails/active_storage/blobs/redirect/").and end_with("/image.gif")
    end

    it "returns link tag with default label" do
      tag = tag_class.new(context: page, params: [frag.identifier, { "as" => "link" }])
      expect(Capybara.string(tag.content)).to have_css("a[target='_blank']", text: "image.jpg")
    end

    it "returns link tag with class and label" do
      options = { "as" => "link", "class" => "custom", "label" => "label" }
      tag = tag_class.new(context: page, params: [frag.identifier, options])
      expect(Capybara.string(tag.content)).to have_css("a.custom[target='_blank']", text: "label")
    end

    it "returns image tag" do
      tag = tag_class.new(context: page, params: [frag.identifier, { "as" => "image" }])
      expect(Capybara.string(tag.content)).to have_css("img[alt='image.jpg']")
    end

    it "returns image tag with class and label" do
      options = { "as" => "image", "class" => "custom", "label" => "label" }
      tag = tag_class.new(context: page, params: [frag.identifier, options])
      expect(Capybara.string(tag.content)).to have_css("img.custom[alt='label']")
    end

    it "returns variant url" do
      options = { "resize_to_limit" => "50x100" }
      tag = tag_class.new(context: page, params: [frag.identifier, options])
      expect(tag.content).to start_with("/rails/active_storage/representations/redirect/").and end_with("/image.jpg")
    end

    context "when selecting by filename" do
      before do
        frag.attachments.attach(fixture_file_upload("image.gif", "image/gif"))
      end

      it "shows only one attachment if filename is passed in" do
        options = { "filename" => "image.gif" }
        tag = tag_class.new(context: page, params: [frag.identifier, options])

        expect(tag.content).to include("image.gif")
        expect(tag.content).not_to include("image.jpg")
      end

      it "shows nothing if filename matches no attachments" do
        options = { "filename" => "invalid.file" }
        tag = tag_class.new(context: page, params: [frag.identifier, options])
        expect(tag.content).to eq("")
      end
    end
  end

  describe "#variant_options" do
    it "converts options into image_processing options" do
      tag = tag_class.new(context: page, params: [frag.identifier, { "resize_to_fill" => "100x50" }])
      expect(tag.variant_options).to eq(resize_to_fill: [100, 50])
    end

    it "only handles one variant option (slice controls the order)" do
      params = { "resize_and_pad" => "50x25", "resize_to_fill" => "100x50" }
      tag = tag_class.new(context: page, params: [frag.identifier, params])
      expect(tag.variant_options).to eq(resize_to_fill: [100, 50])
    end

    it "ignores malformed option" do
      tag = tag_class.new(context: page, params: [frag.identifier, { "resize_to_fill" => "foox50" }])
      expect(tag.variant_options).to eq({})
    end

    it "handles spaces" do
      tag = tag_class.new(context: page, params: [frag.identifier, { "resize_and_pad" => "100 x 50" }])
      expect(tag.variant_options).to eq(resize_and_pad: [100, 50])
    end

    it "limits image dimensions" do
      tag = tag_class.new(context: page, params: [frag.identifier, { "resize_to_fit" => "9999999 x 999999" }])
      expect(tag.variant_options).to eq(resize_to_fit: [2500, 2500])
    end
  end
end
