# frozen_string_literal: true

require "rails_helper"

RSpec.describe Comfy::Cms::Site do
  let(:site) { comfy_cms_sites(:default) }

  it_behaves_like "model with valid fixture data"
  it_behaves_like "model with presence validations", :identifier, :label, :hostname

  describe "normalizations" do
    it "normalizes path" do
      site = described_class.new(path: "/en///test//")
      expect(site.path).to eq("/en/test")

      site = described_class.new(path: nil)
      expect(site.path).to eq("/")

      site = described_class.new(path: "invalid input")
      expect(site.path).to eq("/invalidinput")
    end
  end

  describe "callbacks" do
    describe "#assign_identifier" do
      it "sets identifier" do
        site = described_class.new(hostname: "my-site.host")
        expect(site).to be_valid
        expect(site.identifier).to eq("my-site-host")
      end
    end

    describe "#assign_hostname" do
      it "sets hostname" do
        site = described_class.new(identifier: "test-site")
        expect(site).to be_valid
        expect(site.hostname).to eq("test-site")
      end
    end

    describe "#assign_label" do
      it "sets label" do
        site = described_class.new(identifier: "test", hostname: "my-site.host")
        expect(site).to be_valid
        expect(site.label).to eq("Test")
      end
    end
  end

  describe "validations" do
    it "has unique path for hostnames" do
      new_site = described_class.new(
        identifier: "test",
        hostname:   site.hostname,
        path:       site.path
      )
      expect(new_site).to be_invalid
      expect(new_site.errors[:hostname]).to include("has already been taken")

      new_site.path = "test"
      expect(new_site).to be_valid
    end

    it "has hostname format validations" do
      site = described_class.new(identifier: "test", hostname: "http://site.host")
      expect(site).to be_invalid
      expect(site.errors[:hostname]).to include("is invalid")

      site = described_class.new(identifier: "test", hostname: "localhost:3000")
      expect(site).to be_valid
    end

    it "checks if identifier is globally unique" do
      new_site = described_class.new(identifier: site.identifier, hostname: "site.host")
      expect(new_site).to be_invalid
      expect(new_site.errors[:identifier]).to include("has already been taken")
    end
  end

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

  describe ".find_site" do
    it "finds site if there's only one regardless of host and path" do
      expect(described_class.find_site(hostname: site.hostname)).to eq(site)
      expect(described_class.find_site(hostname: site.hostname, path: "/invalid")).to eq(site)
      expect(described_class.find_site(hostname: "invalid", path: "/invalid")).to eq(site)
    end

    it "finds site when there are others" do
      site_b = described_class.create!(identifier: "test_a", hostname: "test2.host", path: "en")
      site_c = described_class.create!(identifier: "test_b", hostname: "test2.host", path: "fr")

      expect(described_class.find_site(hostname: site.hostname)).to eq(site)
      expect(described_class.find_site(hostname: site.hostname, path: "/any-path")).to eq(site)

      expect(described_class.find_site(hostname: "invalid.host")).to be_nil

      expect(described_class.find_site(hostname: site_b.hostname)).to be_nil
      expect(described_class.find_site(hostname: site_b.hostname, path: "/any-path")).to be_nil
      expect(described_class.find_site(hostname: site_b.hostname, path: "/en")).to eq(site_b)
      expect(described_class.find_site(hostname: site_b.hostname, path: "/en?foo=bar")).to eq(site_b)
      expect(described_class.find_site(hostname: site_b.hostname, path: "/en/any-path?foo=bar")).to eq(site_b)

      expect(described_class.find_site(hostname: site_c.hostname, path: "/fr")).to eq(site_c)
    end

    it "finds site when public_cms_path is defined" do
      ComfortableMexicanSofa.config.public_cms_path = "/custom"

      expect(site.url).to eq("//www.example.com/custom")

      site_b = described_class.create!(identifier: "test_a", hostname: "test2.host", path: "en")
      site_c = described_class.create!(identifier: "test_b", hostname: "test2.host", path: "fr")

      expect(described_class.find_site(hostname: site_b.hostname)).to be_nil
      expect(described_class.find_site(hostname: site_b.hostname, path: "/custom/any-path")).to be_nil
      expect(described_class.find_site(hostname: site_b.hostname, path: "/en")).to be_nil
      expect(described_class.find_site(hostname: site_b.hostname, path: "/custom/en")).to eq(site_b)

      expect(described_class.find_site(hostname: site_c.hostname, path: "/fr")).to be_nil
      expect(described_class.find_site(hostname: site_c.hostname, path: "/custom/fr")).to eq(site_c)
    end

    it "finds site when hostname_aliases are defined" do
      ComfortableMexicanSofa.config.hostname_aliases = {
        "www.example.com" => "alias.host",
        "test2.host"      => %w[foo.host bar.host]
      }

      site_b = described_class.create!(identifier: "site_b", hostname: "test2.host")

      expect(described_class.find_site(hostname: "alias.host")).to eq(site)
      expect(described_class.find_site(hostname: "foo.host")).to eq(site_b)
      expect(described_class.find_site(hostname: "bar.host")).to eq(site_b)
    end
  end

  describe "#url" do
    it "returns site url" do
      expect(site.url).to eq("//www.example.com")
    end

    context "with path" do
      before do
        site.update_column(:path, "/some-path")
      end

      it "returns site url with path" do
        expect(site.url).to eq("//www.example.com/some-path")
      end

      it "returns site url when public_cms_path is defined" do
        ComfortableMexicanSofa.config.public_cms_path = "cms"
        expect(site.url).to eq("//www.example.com/cms/some-path")
      end

      it "returns site url when relative flag is active" do
        ComfortableMexicanSofa.config.public_cms_path = "cms"
        expect(site.url(relative: true)).to eq("/cms/some-path")
      end
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
