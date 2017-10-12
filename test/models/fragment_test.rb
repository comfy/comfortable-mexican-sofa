require_relative '../test_helper'

class CmsFragmentTest < ActiveSupport::TestCase

  setup do
    @site   = comfy_cms_sites(:default)
    @layout = comfy_cms_layouts(:default)
    @page   = comfy_cms_pages(:default)
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

  def test_fixtures_validity
    Comfy::Cms::Fragment.all.each do |block|
      assert block.valid?, block.errors.full_messages.to_s
    end
  end

  def test_validation
    frag = Comfy::Cms::Fragment.new
    refute frag.valid?
    assert_has_errors_on frag, :identifier, :page
  end

  def test_content_assignment
    fragment = Comfy::Cms::Fragment.new

    fragment.content = 'test'
    assert_equal 'test', fragment.content

    fragment.content = 12345
    assert_equal 12345, fragment.content

    fragment.content = [1, 2, 3]
    assert_equal [1, 2, 3], fragment.content
  end

  def test_content_files
    frag = Comfy::Cms::Fragment.new
    assert_equal [], frag.content_files

    upload = fixture_file_upload('files/image.jpg', 'image/jpeg')
    frag.content_files = upload
    assert_equal [upload], frag.content_files
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
    frag_count        = -> {Comfy::Cms::Fragment.count}
    attachment_count  = -> {ActiveStorage::Attachment.count}
    assert_difference [frag_count, attachment_count] do
      frag = @page.fragments.create!(
        identifier:     "test",
        content_files:  fixture_file_upload('files/image.jpg', 'image/jpeg')
      )
      assert frag.files.attached?
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
    page = @site.pages.create!(page_params([{
      identifier:   'test',
      the_cunt: fixture_file_upload('files/image.jpg', 'image/jpeg')
    }]))
  end

  def test_creation_and_update_via_nested_attributes_with_file
    flunk
  end

  def test_creation_and_update_via_nested_attributes_with_files
    flunk
  end


end
