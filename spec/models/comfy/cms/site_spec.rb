# frozen_string_literal: true

require "rails_helper"

RSpec.describe Comfy::Cms::Site do
  let(:site) { comfy_cms_sites(:default) }

  it_behaves_like "model with valid fixture data"
  it_behaves_like "model with presence validations", :identifier, :label, :hostname

  describe ".create" do
    it "creates site record" do
      site = described_class.create(
        identifier: "test",
        label:      "Test Site",
        hostname:   "test.test"
      )
      expect(site).to be_persisted
    end
  end

  describe "#destroy" do
    it "removes site and all dependent records" do
      expect do
        site.destroy
      end.to change(Comfy::Cms::Site, :count).by(-1)
        .and change(Comfy::Cms::Layout, :count).by(-3)
        .and change(Comfy::Cms::Page, :count).by(-2)
        .and change(Comfy::Cms::Snippet, :count).by(-1)
        .and change(Comfy::Cms::Category, :count).by(-1)
    end
  end

end
