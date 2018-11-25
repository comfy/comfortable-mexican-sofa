# frozen_string_literal: true

require_relative "../test_helper"

class CmsSnippetTest < ActiveSupport::TestCase

  setup do
    @site = comfy_cms_sites(:default)
  end

  def test_fixtures_validity
    Comfy::Cms::Snippet.all.each do |snippet|
      assert snippet.valid?, snippet.errors.full_messages.to_s
    end
  end

  def test_validations
    snippet = Comfy::Cms::Snippet.new
    snippet.save
    assert snippet.invalid?
    assert_has_errors_on snippet, :site, :label, :identifier
  end

  def test_label_assignment
    snippet = @site.snippets.new(
      identifier: "test"
    )
    assert snippet.valid?
    assert_equal "Test", snippet.label
  end

  def test_create
    assert_difference "Comfy::Cms::Snippet.count" do
      snippet = @site.snippets.create(
        label:      "Test Snippet",
        identifier: "test",
        content:    "Test Content"
      )
      assert_equal "Test Snippet", snippet.label
      assert_equal "test", snippet.identifier
      assert_equal "Test Content", snippet.content
      assert_equal 1, snippet.position
    end
  end

  def test_update_forces_page_content_reload
    snippet = comfy_cms_snippets(:default)
    page    = comfy_cms_pages(:default)
    comfy_cms_fragments(:default).update_column(:content, "{{cms:snippet default}}")
    page.clear_content_cache!

    assert_equal "snippet content", page.content_cache
    snippet.update(content: "new snippet content")
    page.reload
    assert_equal "new snippet content", page.content_cache
  end

end
