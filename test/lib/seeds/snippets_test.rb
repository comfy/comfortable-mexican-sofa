# frozen_string_literal: true

require_relative "../../test_helper"

class SeedsSnippetsTest < ActiveSupport::TestCase

  setup do
    @site     = comfy_cms_sites(:default)
    @snippet  = comfy_cms_snippets(:default)
  end

  def test_creation
    Comfy::Cms::Snippet.delete_all

    assert_difference -> { Comfy::Cms::Snippet.count } do
      ComfortableMexicanSofa::Seeds::Snippet::Importer.new("sample-site", "default-site").import!
    end

    snippet = Comfy::Cms::Snippet.last

    assert_equal "default", snippet.identifier
    assert_equal "Default Seed Snippet", snippet.label
    assert_equal "Default Seed Snippet Content\n", snippet.content

    assert_equal %w[category_a category_b], snippet.categories.map(&:label)
  end

  def test_update
    @snippet.update_column(:updated_at, 10.years.ago)
    assert_equal "default", @snippet.identifier
    assert_equal "Default Snippet", @snippet.label
    assert_equal "snippet content", @snippet.content

    assert_no_difference -> { Comfy::Cms::Snippet.count } do
      ComfortableMexicanSofa::Seeds::Snippet::Importer.new("sample-site", "default-site").import!
    end

    @snippet.reload
    assert_equal "default", @snippet.identifier
    assert_equal "Default Seed Snippet", @snippet.label
    assert_equal "Default Seed Snippet Content\n", @snippet.content
  end

  def test_delete
    old_snippet = @snippet
    old_snippet.update_column(:identifier, "old")

    assert_no_difference -> { Comfy::Cms::Snippet.count } do
      ComfortableMexicanSofa::Seeds::Snippet::Importer.new("sample-site", "default-site").import!
    end

    assert snippet = Comfy::Cms::Snippet.last
    assert_equal "default", snippet.identifier
    assert_equal "Default Seed Snippet", snippet.label
    assert_equal "Default Seed Snippet Content\n", snippet.content

    assert_nil Comfy::Cms::Snippet.where(id: old_snippet.id).first
  end

  def test_update_ignoring
    snippet_path = File.join(ComfortableMexicanSofa.config.seeds_path, "sample-site", "snippets")
    content_path = File.join(snippet_path, "default.html")

    assert @snippet.updated_at >= File.mtime(content_path)

    ComfortableMexicanSofa::Seeds::Snippet::Importer.new("sample-site", "default-site").import!
    @snippet.reload
    assert_equal "default", @snippet.identifier
    assert_equal "Default Snippet", @snippet.label
    assert_equal "snippet content", @snippet.content
  end

  def test_export
    comfy_cms_categories(:default).categorizations.create!(
      categorized: @snippet
    )

    host_path     = File.join(ComfortableMexicanSofa.config.seeds_path, "test-site")
    content_path  = File.join(host_path, "snippets/default.html")

    ComfortableMexicanSofa::Seeds::Snippet::Exporter.new("default-site", "test-site").export!

    assert File.exist?(content_path)
    out = <<~TEXT.chomp
      [attributes]
      ---
      label: Default Snippet
      categories:
      - Default
      position: 0
      [content]
      snippet content
    TEXT
    assert_equal out, IO.read(content_path)

  ensure
    FileUtils.rm_rf(host_path)
  end

end
