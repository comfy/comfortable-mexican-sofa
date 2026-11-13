# frozen_string_literal: true

require "rails_helper"

RSpec.describe Comfy::Cms::ActsAsTreeConcern do
  let(:root_page)    { comfy_cms_pages(:default) }
  let(:page_a)       { comfy_cms_pages(:page_a) }
  let(:page_b)       { comfy_cms_pages(:page_b) }
  let(:page_a_child) { comfy_cms_pages(:page_a_child) }

  describe "relationships" do
    it "belongs to parent" do
      expect(page_a.parent).to eq(root_page)
    end

    it "has many children" do
      expect(root_page.children).to contain_exactly(page_a, page_b)
    end
  end

  describe "validations" do
    describe "#validate_parent_id" do
      it "ensures that record cannot be parent of itself" do
        page_a.parent_id = page_a.id
        expect(page_a).not_to be_valid
        expect(page_a.errors[:parent_id]).to include("cannot be its own parent")
      end

      it "ensures that record cannot be a child of one of its own descendants" do
        root_page.parent_id = page_a.id
        expect(root_page).not_to be_valid
        expect(root_page.errors[:parent_id]).to include("cannot be a descendant's parent")
      end
    end

    describe "#validate_site_scoping" do
      it "cannot link to a record outside site scope" do
        root_page.update_column(:site_id, 9999)
        expect(page_a).not_to be_valid
        expect(page_a.errors[:parent_id]).to include("wrong site scope")
      end
    end
  end

  describe "scopes" do
    describe ".roots" do
      it "returns collection of root records" do
        expect(Comfy::Cms::Page.roots).to contain_exactly(root_page)
        page_a.update_column(:parent_id, nil)
        expect(Comfy::Cms::Page.roots).to contain_exactly(root_page, page_a)
      end
    end
  end

  describe ".tree" do
    it "returns tree structure of records" do
      expected = [
        {
          id:       root_page.id,
          label:    root_page.label,
          children: [
            {
              id:       page_a.id,
              label:    page_a.label,
              children: [
                {
                  id:       page_a_child.id,
                  label:    page_a_child.label,
                  children: []
                }
              ]
            }, {
              id:       page_b.id,
              label:    page_b.label,
              children: []
            }
          ]
        }
      ]
      expect(Comfy::Cms::Page.tree(records: Comfy::Cms::Page.all)).to eq(expected)
    end

    it "sorts things based on position" do
      page_a.update_column(:position, 99)
      expected = [
        {
          id:       root_page.id,
          label:    root_page.label,
          children: [
            {
              id:       page_b.id,
              label:    page_b.label,
              children: []
            }, {
              id:       page_a.id,
              label:    page_a.label,
              children: [
                {
                  id:       page_a_child.id,
                  label:    page_a_child.label,
                  children: []
                }
              ]
            }
          ]
        }
      ]
      expect(Comfy::Cms::Page.tree(records: Comfy::Cms::Page.all)).to eq(expected)
    end

    it "doesn't crash if there's a non-persisted object in the list" do
      expect do
        Comfy::Cms::Page.tree(records: Comfy::Cms::Page.all.to_a + [Comfy::Cms::Page.new])
      end.not_to raise_error
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
      expect(page_a.root?).to be(false)
    end
  end

  describe "#descendants" do
    it "returns an array of descendant records" do
      expect(root_page.descendants).to contain_exactly(page_a, page_b, page_a_child)
      expect(page_a.descendants).to contain_exactly(page_a_child)
      expect(page_a_child.descendants).to be_blank
    end
  end

  describe "#destroy" do
    it "destroys entire tree" do
      expect do
        root_page.destroy
      end.to change(Comfy::Cms::Page, :count).by(-4)
    end
  end
end
