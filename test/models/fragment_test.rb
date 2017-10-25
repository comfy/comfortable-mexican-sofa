require_relative '../test_helper'

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
      label:                'test page',
      slug:                 'test_page',
      parent_id:            @page.id,
      fragments_attributes: frag_params
    }
  end

  # -- Tests -------------------------------------------------------------------

  def test_initialization
    frag = Comfy::Cms::Fragment.new
    assert_equal "text", frag.format
  end

  def test_fixtures_validity
    Comfy::Cms::Fragment.all.each do |frag|
      assert frag.valid?, frag.errors.full_messages.to_s
    end
  end

  def test_validation
    frag = Comfy::Cms::Fragment.new
    refute frag.valid?
    assert_has_errors_on frag, :identifier, :page
  end

  def test_content_serialization
    fragment = Comfy::Cms::Fragment.new

    fragment.content = 'test'
    assert_equal 'test', fragment.content

    fragment.content = 12345
    assert_equal 12345, fragment.content

    fragment.content = [1, 2, 3]
    assert_equal [1, 2, 3], fragment.content
  end

  def test_content_files
    frag = Comfy::Cms::Fragment.new(format: "file")
    assert_equal [], frag.content.to_a

    upload = fixture_file_upload('files/image.jpg', 'image/jpeg')

    frag.content = upload
    assert_equal [upload], frag.content
  end

  def test_content_datetime
    frag = Comfy::Cms::Fragment.new(format: "datetime")
    assert_nil frag.content
    frag.content = DateTime.parse("1981-10-04 01:02:03")
    assert_equal "1981-10-04 01:02:03 UTC", frag.content.to_s
  end

  def test_content_date
    frag = Comfy::Cms::Fragment.new(format: "date")
    assert_nil frag.content
    frag.content = DateTime.parse("1981-10-04")
    assert_equal "1981-10-04 00:00:00 UTC", frag.content.to_s
  end

  def test_content_boolean
    frag = Comfy::Cms::Fragment.new(format: "boolean")
    refute frag.content
    frag.content = "true"
    assert frag.content
    frag.content = "false"
    refute frag.content
  end

  def test_content_undefined
    frag = Comfy::Cms::Fragment.new(format: "undefined")
    assert_nil frag.content
    frag.content = "content"
    assert_equal "content", frag.content
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
    assert_count_difference [Comfy::Cms::Fragment] do
      assert_count_difference [ActiveStorage::Attachment], 2 do
        frag = @page.fragments.create!(
          identifier: "test",
          format:     "files",
          files:      [@upload_doc, @upload_img]
        )
        assert_equal 2, frag.attachments.count
      end
    end
  end

  def test_creation_with_file
    assert_count_difference [Comfy::Cms::Fragment, ActiveStorage::Attachment] do
      frag = @page.fragments.create!(
        identifier: "test",
        format:     "file",
        files:      [@upload_doc, @upload_img]
      )
      assert_equal 1, frag.attachments.count
    end
  end

  def test_update_with_files
    frag = comfy_cms_fragments(:file)
    assert_equal 1, frag.attachments.count
    assert_equal "fragment.jpg", frag.attachments.first.filename.to_s
    assert_difference -> {frag.attachments.count} do
      frag.update_attributes(
        format: "files",
        files: [@upload_doc]
      )
    end
  end

  def test_update_with_file
    frag = comfy_cms_fragments(:file)
    assert_equal 1, frag.attachments.count
    assert_equal "fragment.jpg", frag.attachments.first.filename.to_s
    assert_no_difference -> {frag.attachments.count} do
      frag.update_attributes(
        format: "file",
        files: [@upload_doc]
      )
    end
    frag.reload
    assert_equal "document.pdf", frag.attachments.first.filename.to_s
  end

  def test_update_with_file_removal
    frag = comfy_cms_fragments(:file)
    assert_difference -> {frag.attachments.count}, -1 do
      frag.update_attributes(
        file_ids_destroy: frag.attachments.pluck(:id)
      )
    end
  end

  def test_creation_via_page_nested_attributes
    assert_difference ['Comfy::Cms::Page.count', 'Comfy::Cms::Fragment.count'] do
      page = @site.pages.create!(page_params([{
        identifier: 'default_page_text',
        content:    'test_content'
      }]))
      assert_equal 1, page.fragments.count
      fragment = page.fragments.first
      assert_equal 'default_page_text', fragment.identifier
      assert_equal 'test_content', fragment.content
    end
  end

  def test_creation_via_page_nested_attributes_as_hash
    assert_difference ['Comfy::Cms::Page.count', 'Comfy::Cms::Fragment.count'] do
      page = @site.pages.create!(page_params({
        '0' => {
          identifier: 'default_page_text',
          content:    'test_content'
        }
      }))
      assert_equal 1, page.fragments.count
      fragment = page.fragments.first
      assert_equal 'default_page_text', fragment.identifier
      assert_equal 'test_content', fragment.content
    end
  end

  def test_creation_via_page_nested_attributes_as_hash_with_duplicates
    assert_difference ['Comfy::Cms::Page.count', 'Comfy::Cms::Fragment.count'] do
      page = @site.pages.create!(page_params({
        '0' => {
          identifier: 'default_page_text',
          content:    'test_content'
        },
        '1' => {
          identifier: 'default_page_text',
          content:    'test_content'
        }
      }))
      assert_equal 1, page.fragments.count
      fragment = page.fragments.first
      assert_equal 'default_page_text', fragment.identifier
      assert_equal 'test_content', fragment.content
    end
  end

  def test_creation_via_nested_attributes_with_file
    attachment = fixture_file_upload("files/image.jpg", "image/jpeg")
    page = @site.pages.create!(page_params([{
      identifier:   "test",
      format:       "file",
      content:      attachment
    }]))
    assert_equal 1, page.fragments.count
    frag = page.fragments.first
    assert_equal "test", frag.identifier
    assert_equal "file", frag.format
    assert_equal [attachment], frag.content
    assert_equal 1, frag.attachments.count
  end
end
