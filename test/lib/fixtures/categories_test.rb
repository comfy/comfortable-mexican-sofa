# encoding: utf-8

require_relative '../../test_helper'

class FixtureCategoriesTest < ActiveSupport::TestCase
  
  def test_creation
    assert_difference 'Cms::Category.count', 3 do
      ComfortableMexicanSofa::Fixture::Category::Importer.new('sample-site', 'default-site').import!
      assert Cms::Category.where(:label => 'File Category', :categorized_type => 'Cms::File').present?
      assert Cms::Category.where(:label => 'Page Category', :categorized_type => 'Cms::Page').present?
      assert Cms::Category.where(:label => 'Snippet Category', :categorized_type => 'Cms::Snippet').present?
    end
  end
  
  def test_export
    Cms::Category.delete_all
    cms_sites(:default).categories.create!(:label => 'File',    :categorized_type => 'Cms::File')
    cms_sites(:default).categories.create!(:label => 'Page',    :categorized_type => 'Cms::Page')
    cms_sites(:default).categories.create!(:label => 'Snippet', :categorized_type => 'Cms::Snippet')
    
    host_path = File.join(ComfortableMexicanSofa.config.fixtures_path, 'test-site')
    ComfortableMexicanSofa::Fixture::Category::Exporter.new('default-site', 'test-site').export!
    files_path    = File.join(host_path, 'categories/files.yml')
    pages_path    = File.join(host_path, 'categories/pages.yml')
    snippets_path = File.join(host_path, 'categories/snippets.yml')
    
    assert_equal ['File'],    YAML.load_file(files_path)
    assert_equal ['Page'],    YAML.load_file(pages_path)
    assert_equal ['Snippet'], YAML.load_file(snippets_path)
    
    FileUtils.rm_rf(host_path)
  end
  
end