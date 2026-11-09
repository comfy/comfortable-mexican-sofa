# frozen_string_literal: true

require "rails_helper"

RSpec.describe Comfy::Cms::ActsAsTreeConcern do
  let(:root_page)  { comfy_cms_pages(:default) }
  let(:child_page) { comfy_cms_pages(:child) }

  describe "relationships" do
    it "belongs to parent" do
      expect(child_page.parent).to eq(root_page)
    end

    it "has many children" do
      expect(root_page.children).to contain_exactly(child_page)
    end
  end

  describe "validations" do
    describe "#validate_parent_id" do
      it "ensures that record cannot be parent of itself" do
        child_page.parent_id = child_page.id
        expect(child_page).not_to be_valid
        expect(child_page.errors[:parent_id]).to include("cannot be its own parent")
      end

      it "ensures that record cannot be a child of one of its own descendants" do
        root_page.parent_id = child_page.id
        expect(root_page).not_to be_valid
        expect(root_page.errors[:parent_id]).to include("cannot be a descendant's parent")
      end
    end

    describe "#validate_site_scoping" do
      it "cannot link to a record outside site scope" do
        root_page.update_column(:site_id, 9999)
        expect(child_page).not_to be_valid
        expect(child_page.errors[:parent_id]).to include("wrong site scope")
      end
    end
  end

  describe "scopes" do
    describe ".roots" do
      it "returns collection of root records" do
        expect(Comfy::Cms::Page.roots).to contain_exactly(root_page)
        child_page.update_column(:parent_id, nil)
        expect(Comfy::Cms::Page.roots).to contain_exactly(root_page, child_page)
      end
    end
  end

  describe ".root" do
    it "returns first root record it finds" do
      expect(Comfy::Cms::Page.root).to eq(root_page)
    end
  end

  describe "#root?" do
    it "returns boolean" do
      expect(root_page.root?).to be(true)
      expect(child_page.root?).to be(false)
    end
  end

  describe "#descendants" do
    it "returns an array of descendant records" do
      expect(root_page.descendants).to contain_exactly(child_page)
    end
  end
end
