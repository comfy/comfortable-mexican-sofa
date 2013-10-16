# encoding: utf-8

require_relative '../../test_helper'

class FixtureFilesTest < ActiveSupport::TestCase
  
  def test_creation
    Cms::File.delete_all
    
    assert_difference 'Cms::File.count' do
      ComfortableMexicanSofa::Fixture::File::Importer.new('sample-site', 'default-site').import!
      assert file = Cms::File.last
      
      assert_equal 'Fixture File',       file.label
      assert_equal 'sample.jpg',           file.file_file_name
      assert_equal 'Fixture Description', file.description
      
      assert_equal 2, file.categories.count
      assert_equal ['category_a', 'category_b'], file.categories.map{|c| c.label}
    end
  end
  
  def test_update
    file = cms_files(:default)
    file.update_column(:updated_at, 10.years.ago)
    assert_equal 'sample.jpg',           file.file_file_name
    assert_equal 'Default File',        file.label
    assert_equal 'Default Description', file.description
    
    assert_no_difference 'Cms::Snippet.count' do
      ComfortableMexicanSofa::Fixture::File::Importer.new('sample-site', 'default-site').import!
      file.reload
      assert_equal 'sample.jpg',           file.file_file_name
      assert_equal 'Fixture File',       file.label
      assert_equal 'Fixture Description', file.description
    end
  end
  
  def test_update_ignore
    file = cms_files(:default)
    file_path = File.join(ComfortableMexicanSofa.config.fixtures_path, 'sample-site', 'files', 'sample.jpg')
    attr_path = File.join(ComfortableMexicanSofa.config.fixtures_path, 'sample-site', 'files', '_sample.jpg.yml')
    
    assert file.updated_at >= File.mtime(file_path)
    assert file.updated_at >= File.mtime(attr_path)
    
    ComfortableMexicanSofa::Fixture::File::Importer.new('sample-site', 'default-site').import!
    file.reload
    assert_equal 'sample.jpg',          file.file_file_name
    assert_equal 'Default File',        file.label
    assert_equal 'Default Description', file.description
  end
  
  def test_update_force
    file = cms_files(:default)
    ComfortableMexicanSofa::Fixture::File::Importer.new('sample-site', 'default-site').import!
    file.reload
    assert_equal 'Default File', file.label
    
    ComfortableMexicanSofa::Fixture::File::Importer.new('sample-site', 'default-site', :forced).import!
    file.reload
    assert_equal 'Fixture File', file.label
  end
  
  def test_delete
    old_file = cms_files(:default)
    old_file.update_column(:file_file_name, 'old')
    
    assert_no_difference 'Cms::File.count' do
      ComfortableMexicanSofa::Fixture::File::Importer.new('sample-site', 'default-site').import!
      assert file = Cms::File.last
      assert_equal 'sample.jpg',          file.file_file_name
      assert_equal 'Fixture File',        file.label
      assert_equal 'Fixture Description', file.description
      
      assert Cms::File.where(:id => old_file.id).blank?
    end
  end
  
  def test_export
    host_path = File.join(ComfortableMexicanSofa.config.fixtures_path, 'test-site')
    attr_path = File.join(host_path, 'files/_sample.jpg.yml')
    file_path = File.join(host_path, 'files/sample.jpg')
    
    Paperclip::Attachment.any_instance.stubs(:path).
      returns(File.join(Rails.root, 'db/cms_fixtures/sample-site/files/sample.jpg'))
    ComfortableMexicanSofa::Fixture::File::Exporter.new('default-site', 'test-site').export!
    
    assert File.exists?(attr_path)
    assert File.exists?(file_path)
    assert_equal ({
      'label'       => 'Default File',
      'description' => 'Default Description',
      'categories'  => ['Default']
    }), YAML.load_file(attr_path)
    
    FileUtils.rm_rf(host_path)
  end
  
end