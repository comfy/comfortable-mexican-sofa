# encoding: utf-8

require_relative '../../../test_helper'

class FixtureSnippetImporterTest < ActiveSupport::TestCase

  def test_creation
    Cms::Snippet.delete_all

    assert_difference 'Cms::Snippet.count' do
      importer.import!
      assert snippet = Cms::Snippet.last
      assert_equal 'default', snippet.identifier
      assert_equal 'Default Fixture Snippet', snippet.label
      assert_equal 'Fixture Content for Default Snippet', snippet.content
      assert_equal 2, snippet.categories.count
      assert_equal ['category_a', 'category_b'], snippet.categories.map{|c| c.label}
    end
  end

  def test_update
    snippet = cms_snippets(:default)
    snippet.update_column(:updated_at, 10.years.ago)
    assert_equal 'default', snippet.identifier
    assert_equal 'Default Snippet', snippet.label
    assert_equal 'default_snippet_content', snippet.content

    assert_no_difference 'Cms::Snippet.count' do
      importer.import!
      snippet.reload
      assert_equal 'default', snippet.identifier
      assert_equal 'Default Fixture Snippet', snippet.label
      assert_equal 'Fixture Content for Default Snippet', snippet.content
    end
  end

  def test_delete
    old_snippet = cms_snippets(:default)
    old_snippet.update_column(:identifier, 'old')

    assert_no_difference 'Cms::Snippet.count' do
      importer.import!
      assert snippet = Cms::Snippet.last
      assert_equal 'default', snippet.identifier
      assert_equal 'Default Fixture Snippet', snippet.label
      assert_equal 'Fixture Content for Default Snippet', snippet.content

      assert_nil Cms::Snippet.where(:id => old_snippet.id).first
    end
  end

  def test_update_ignoring
    snippet = cms_snippets(:default)
    snippet_path      = File.join(ComfortableMexicanSofa.config.fixtures_path, 'sample-site', 'snippets', 'default')
    attr_file_path    = File.join(snippet_path, 'attributes.yml')
    content_file_path = File.join(snippet_path, 'content.html')

    assert snippet.updated_at >= File.mtime(attr_file_path)
    assert snippet.updated_at >= File.mtime(content_file_path)

    importer.import!
    snippet.reload
    assert_equal 'default', snippet.identifier
    assert_equal 'Default Snippet', snippet.label
    assert_equal 'default_snippet_content', snippet.content
  end

  def test_update_force
    snippet = cms_snippets(:default)
    importer.import!
    snippet.reload
    assert_equal 'Default Snippet', snippet.label

    importer(:forced).import!
    snippet.reload
    assert_equal 'Default Fixture Snippet', snippet.label
  end

  private
  def importer *args
    ComfortableMexicanSofa::Fixture::Snippet::Importer.new('sample-site', 'default-site', *args)
  end
end
