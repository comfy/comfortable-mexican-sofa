# encoding: utf-8

require_relative '../../test_helper'

class FixtureSnippetsTest < ActiveSupport::TestCase
  
  def test_creation
    Cms::Snippet.delete_all
    
    assert_difference 'Cms::Snippet.count' do
      ComfortableMexicanSofa::Fixture::Snippet::Importer.new('sample-site', 'default-site').import!
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
      ComfortableMexicanSofa::Fixture::Snippet::Importer.new('sample-site', 'default-site').import!
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
      ComfortableMexicanSofa::Fixture::Snippet::Importer.new('sample-site', 'default-site').import!
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
    
    ComfortableMexicanSofa::Fixture::Snippet::Importer.new('sample-site', 'default-site').import!
    snippet.reload
    assert_equal 'default', snippet.identifier
    assert_equal 'Default Snippet', snippet.label
    assert_equal 'default_snippet_content', snippet.content
  end
  
  def test_update_force
    snippet = cms_snippets(:default)
    ComfortableMexicanSofa::Fixture::Snippet::Importer.new('sample-site', 'default-site').import!
    snippet.reload
    assert_equal 'Default Snippet', snippet.label
    
    ComfortableMexicanSofa::Fixture::Snippet::Importer.new('sample-site', 'default-site', :forced).import!
    snippet.reload
    assert_equal 'Default Fixture Snippet', snippet.label
  end
  
  def test_export
    cms_categories(:default).categorizations.create!(
      :categorized => cms_snippets(:default)
    )
    
    host_path = File.join(ComfortableMexicanSofa.config.fixtures_path, 'test-site')
    attr_path     = File.join(host_path, 'snippets/default/attributes.yml')
    content_path  = File.join(host_path, 'snippets/default/content.html')
    
    ComfortableMexicanSofa::Fixture::Snippet::Exporter.new('default-site', 'test-site').export!
    
    assert File.exists?(attr_path)
    assert File.exists?(content_path)
    assert_equal ({
      'label'       => 'Default Snippet',
      'categories'  => ['Default']
    }), YAML.load_file(attr_path)
    assert_equal cms_snippets(:default).content, IO.read(content_path)
    
    FileUtils.rm_rf(host_path)
  end
  
end
