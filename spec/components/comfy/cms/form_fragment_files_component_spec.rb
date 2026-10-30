# frozen_string_literal: true

require "rails_helper"

RSpec.describe Comfy::Cms::FormFragmentFilesComponent do
  let(:frag)      { comfy_cms_fragments(:file) }
  let(:component) { described_class.new(object_name: "page", index: 0, fragment: frag) }

  describe "#call" do
    it "renders component" do
      render_inline(component)

      container = page.find("comfy--cms--form-fragment-files-component .attachment")
      expect(container).to have_link("image.jpg", href: %r{/rails/active_storage/blobs})
      expect(container).to have_css(".variant-tooltip img[src*='rails/active_storage/representations']")
      expect(container).to have_field("page[fragments_attributes][0][file_ids_destroy][]", type: "checkbox")
    end

    it "renders for multiple attachments" do
      frag.attachments.attach(fixture_file_upload("data.zip", "application/zip"))
      render_inline(component)

      container = page.find("comfy--cms--form-fragment-files-component")
      expect(container).to have_css(".attachment", count: 2)
    end

    it "does not render tooltip for non-image attachments" do
      frag.attachments.purge
      frag.attachments.attach(fixture_file_upload("data.zip", "application/zip"))
      render_inline(component)

      container = page.find("comfy--cms--form-fragment-files-component")
      expect(container).to have_no_css(".variant-tooltip")
    end

    it "renders nothing if fragment has no attachments" do
      frag.attachments.purge
      render_inline(component)

      expect(page).to have_no_css("comfy--cms--form-fragment-files-component")
    end

    it "truncates very long filenames" do
      frag.attachments.purge
      file = fixture_file_upload("data.zip", "application/zip")
      super_long_name = "this-filename-is-very-long-and-cannot-fit.not-a-virus.mp3.exe"
      file.define_singleton_method(:original_filename) { super_long_name }
      frag.attachments.attach(file)

      render_inline(component)

      expect(page).to have_link("this-filename-is-...us.mp3.exe")
    end
  end
end
