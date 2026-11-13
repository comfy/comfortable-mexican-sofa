# frozen_string_literal: true

require "rails_helper"

RSpec.describe ComfortableMexicanSofa::Content::Tag::DatetimeTag do
  include ActionView::TestCase::Behavior

  let(:page) { comfy_cms_pages(:default) }
  let(:frag) { comfy_cms_fragments(:datetime) }

  it "is registered with renderer" do
    expect(ComfortableMexicanSofa::Content::Renderer.tags["datetime"]).to eq(described_class)
  end

  describe ".new" do
    it "initializes tag" do
      tag = described_class.new(context: page, params: ["test"])
      expect(tag.identifier).to eq("test")
    end
  end

  describe "#content" do
    it "returns fragment content" do
      tag = described_class.new(context: page, params: [frag.identifier])
      expect(tag.fragment).to eq(frag)
      expect(tag.content).to eq(frag.datetime)
    end
  end

  describe "#render" do
    it "renders content" do
      tag = described_class.new(context: page, params: [frag.identifier])
      expect(tag.render).to eq("1981-10-04 12:34:56 UTC")
    end

    it "renders content with formatting" do
      tag = described_class.new(context: page, params: [frag.identifier, { "strftime" => "at %I:%M%p" }])
      expect(tag.render).to eq("at 12:34PM")
    end

    it "renders nothing if render flag is false" do
      tag = described_class.new(context: page, params: [frag.identifier, { "render" => "false" }])
      expect(tag.render).to eq("")
    end
  end

  describe "#form_field" do
    it "renders the field" do
      tag = described_class.new(context: page, params: [frag.identifier])
      output = tag.form_field("object_name", view, 0, &:itself)
      expect(Capybara.string(output)).to have_selector(
        :element, "input",
        value:               "1981-10-04 12:34:56",
        type:                "text",
        name:                "object_name[fragments_attributes][0][datetime]",
        id:                  "fragment-datetime",
        class:               "form-control",
        "data-cms-datetime": "true"
      )
    end
  end
end
