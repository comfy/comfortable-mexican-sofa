# frozen_string_literal: true

require_relative "../test_helper"

class CmsFragmentTest < ActiveSupport::TestCase

  setup do
    @site   = comfy_cms_sites(:default)
    @layout = comfy_cms_layouts(:default)
    @page   = comfy_cms_pages(:default)

    @upload_doc = fixture_file_upload("files/document.pdf", "application/pdf")
    @upload_img = fixture_file_upload("files/image.jpg", "image/jpeg")
  end

  def page_params(frag_params = [])
    {
      layout:               @layout,
      label:                "test page",
      slug:                 "test_page",
      parent_id:            @page.id,
      fragments_attributes: frag_params
    }
  end

  # -- Tests -------------------------------------------------------------------

  def test_initialization
    frag = Comfy::Cms::Fragment.new
    assert_equal "text", frag.tag
  end

  def test_fixtures_validity
    Comfy::Cms::Fragment.all.each do |frag|
      assert frag.valid?, frag.errors.full_messages.to_s
    end
  end

  def test_validation
    frag = Comfy::Cms::Fragment.new
    refute frag.valid?
    assert_has_errors_on frag, :identifier, :record
  end

  def test_content_serialization
    fragment = Comfy::Cms::Fragment.new

    fragment.content = "test"
    assert_equal "test", fragment.content

    fragment.content = 123
    assert_equal 123, fragment.content

    fragment.content = [1, 2, 3]
    assert_equal [1, 2, 3], fragment.content
  end

  def test_creation
    assert_difference "Comfy::Cms::Fragment.count" do
      @page.fragments.create!(
        identifier: "test",
        content:    "test content"
      )
    end
  end

  def test_creation_with_files
    assert_difference -> { Comfy::Cms::Fragment.count } do
      assert_difference(-> { ActiveStorage::Attachment.count }, 2) do
        frag = @page.fragments.create!(
          identifier: "test",
          tag:        "files",
          files:      [@upload_doc, @upload_img]
        )
        assert_equal 2, frag.attachments.count
      end
    end
  end

  def test_creation_with_file
    fragment_count    = -> { Comfy::Cms::Fragment.count }
    attachment_count  = -> { ActiveStorage::Attachment.count }

    assert_difference [fragment_count, attachment_count] do
      frag = @page.fragments.create!(
        identifier: "test",
        tag:        "file",
        files:      [@upload_doc, @upload_img]
      )
      assert_equal 1, frag.attachments.count
    end
  end

  def test_update_with_files
    frag = comfy_cms_fragments(:file)
    assert_equal 1, frag.attachments.count
    assert_equal "fragment.jpg", frag.attachments.first.filename.to_s
    assert_difference -> { frag.attachments.count } do
      frag.update(
        tag:    "files",
        files:  [@upload_doc]
      )
    end
  end

  def test_update_with_file
    frag = comfy_cms_fragments(:file)
    assert_equal 1, frag.attachments.count
    assert_equal "fragment.jpg", frag.attachments.first.filename.to_s
    assert_no_difference -> { frag.attachments.count } do
      frag.update(
        tag:    "file",
        files:  [@upload_doc]
      )
    end
    frag.reload
    assert_equal "document.pdf", frag.attachments.first.filename.to_s
  end

  def test_update_with_file_removal
    frag = comfy_cms_fragments(:file)
    assert_difference -> { frag.attachments.count }, -1 do
      frag.update(
        file_ids_destroy: frag.attachments.pluck(:id)
      )
    end
  end

  def test_touch
    timestamp = 2.days.ago
    @page.update_column(:updated_at, timestamp)
    comfy_cms_fragments(:default).update(content: "updated")
    @page.reload
    refute_equal timestamp, @page.updated_at
  end

end
