# frozen_string_literal: true

require_relative "../test_helper"

class RevisionsTest < ActiveSupport::TestCase

  setup do
    @site     = comfy_cms_sites(:default)
    @layout   = comfy_cms_layouts(:default)
    @page     = comfy_cms_pages(:default)
    @snippet  = comfy_cms_snippets(:default)
  end

  def test_fixtures_validity
    assert_equal ({
      "content" => "revision {{cms:fragment content}}",
      "css"     => "revision css",
      "js"      => "revision js" }), comfy_cms_revisions(:layout).data

    assert_equal ({ "fragments_attributes" => [
      { "identifier" => "content", "content" => "old content" },
      { "identifier" => "title",   "content" => "old title" }
    ] }), comfy_cms_revisions(:page).data

    assert_equal ({
      "content" => "revision content"
    }), comfy_cms_revisions(:snippet).data
  end

  def test_init_for_layouts
    assert_equal %w[content css js], @layout.revision_fields
  end

  def test_init_for_pages
    assert_equal ["fragments_attributes"], @page.revision_fields
  end

  def test_init_for_snippets
    assert_equal ["content"], @snippet.revision_fields
  end

  def test_creation_for_layout
    old_attributes = @layout.attributes.slice("content", "css", "js")

    assert_difference -> { @layout.revisions.count } do
      @layout.update!(
        content:  "new {{cms:fragment content}}",
        js:       "new js"
      )
      @layout.reload
      assert_equal 2, @layout.revisions.count
      revision = @layout.revisions.last
      assert_equal old_attributes, revision.data
    end
  end

  def test_creation_for_layout_ignore
    assert_no_difference -> { @layout.revisions.count } do
      @layout.update(label: "new label")
    end
  end

  def test_creation_for_page
    assert_difference -> { @page.revisions.count } do
      @page.update!(
        fragments_attributes:  [
          { identifier: "content",
            content:    "new content" }
        ]
      )
      @page.reload
      assert_equal 2, @page.revisions.count
      revision = @page.revisions.last

      assert_equal ({
        "fragments_attributes" => [
          { identifier: "boolean",
            tag:        "checkbox",
            content:    nil,
            datetime:   nil,
            boolean:    true },
          { identifier: "file",
            tag:        "file",
            content:    nil,
            datetime:   nil,
            boolean:    false },
          { identifier: "datetime",
            tag:        "datetime",
            content:    nil,
            datetime:   comfy_cms_fragments(:datetime).datetime,
            boolean:    false },
          { identifier: "content",
            tag:        "text",
            content:    "content",
            datetime:   nil,
            boolean:    false }
        ]
      }), revision.data
    end
  end

  def test_creation_for_page_ignore
    assert_no_difference -> { @page.revisions.count } do
      @page.update(label: "new label")
    end
  end

  def test_creation_for_snippet
    old_attributes = @snippet.attributes.slice("content")

    assert_difference -> { @snippet.revisions.count } do
      @snippet.update(content: "new content")
      @snippet.reload
      assert_equal 2, @snippet.revisions.count
      revision = @snippet.revisions.last
      assert_equal old_attributes, revision.data
    end
  end

  def test_creation_for_snippet_ignore
    assert_no_difference -> { @snippet.revisions.count } do
      @snippet.update(label: "new label")
    end
  end

  def test_creation_for_new_record
    assert_difference "Comfy::Cms::Snippet.count" do
      assert_no_difference "Comfy::Cms::Revision.count" do
        snippet = @site.snippets.create!(
          label:      "test snippet",
          identifier: "test_snippet",
          content:    "test content"
        )
        assert_equal 0, snippet.revisions.count
      end
    end
  end

  def test_restore_from_revision_for_layout
    revision = comfy_cms_revisions(:layout)

    assert_difference -> { @layout.revisions.count } do
      @layout.restore_from_revision(revision)
      @layout.reload
      assert_equal "revision {{cms:fragment content}}", @layout.content
      assert_equal "revision css", @layout.css
      assert_equal "revision js", @layout.js
    end
  end

  def test_restore_from_revision_for_page
    revision = comfy_cms_revisions(:page)

    assert_difference -> { @page.revisions.count } do
      @page.restore_from_revision(revision)
      @page.reload

      assert_equal [
        { identifier: "boolean",
          tag:        "checkbox",
          content:    nil,
          datetime:   nil,
          boolean: true },
        { identifier: "file",
          tag:        "file",
          content:    nil,
          datetime:   nil,
          boolean:    false },
        { identifier: "datetime",
          tag:        "datetime",
          content:    nil,
          datetime:   comfy_cms_fragments(:datetime).datetime,
          boolean:    false },
        { identifier: "content",
          tag:        "text",
          content:    "old content",
          datetime:   nil,
          boolean:    false },
        { identifier: "title",
          tag:        "text",
          content:    "old title",
          datetime:   nil,
          boolean:    false }
      ], @page.fragments_attributes
    end
  end

  def test_restore_from_revision_for_snippet
    revision = comfy_cms_revisions(:snippet)

    assert_difference -> { @snippet.revisions.count } do
      @snippet.restore_from_revision(revision)
      @snippet.reload
      assert_equal "revision content", @snippet.content
    end
  end

  def test_restore_from_revision_with_wrong_revision_type
    revision = comfy_cms_revisions(:layout)

    assert_no_difference -> { @snippet.revisions.count } do
      @snippet.restore_from_revision(revision)
      @snippet.reload
      assert_equal "snippet content", @snippet.content
    end
  end

  def test_creation_with_limit
    ComfortableMexicanSofa.config.revisions_limit = 1
    revision = comfy_cms_revisions(:snippet)

    assert_equal 1, @snippet.revisions.count

    assert_no_difference -> { @snippet.revisions.count } do
      @snippet.update(content: "new content")
      assert_nil Comfy::Cms::Revision.find_by_id(revision.id)

      @snippet.reload
      revision = @snippet.revisions.last
      assert_equal ({ "content" => "snippet content" }), revision.data
    end
  end

end
