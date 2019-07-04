# frozen_string_literal: true

require_relative "../test_helper"

class CmsFileTest < ActiveSupport::TestCase

  def test_fixtures_validity
    Comfy::Cms::File.all.each do |file|
      assert file.valid?, file.errors.full_messages.to_s
      assert file.attachment
      assert file.attachment.blob
    end
  end

  def test_validations
    file = Comfy::Cms::File.new
    assert file.invalid?
    assert_has_errors_on file, :site, :file, :label
  end

  def test_creation
    assert_difference ["Comfy::Cms::File.count", "ActiveStorage::Attachment.count"] do
      file = comfy_cms_sites(:default).files.create(
        label:        "test",
        description:  "test file",
        file:         fixture_file_upload("files/image.jpg", "image/jpeg")
      )
      assert_equal 1, file.position
    end
  end

  def test_creation_without_label
    assert_difference ["Comfy::Cms::File.count", "ActiveStorage::Attachment.count"] do
      file = comfy_cms_sites(:default).files.create(
        description:  "test file",
        file:         fixture_file_upload("files/image.jpg", "image/jpeg")
      )
      assert_equal 1, file.position
      assert_equal "image.jpg", file.label
    end
  end

  def test_scope_with_images
    assert_equal 1, Comfy::Cms::File.with_attached_attachment.with_images.count
    active_storage_blobs(:default).update_column(:content_type, "application/pdf")
    assert_equal 0, Comfy::Cms::File.with_attached_attachment.with_images.count
  end

end
