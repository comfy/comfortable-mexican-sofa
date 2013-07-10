# encoding: utf-8

require_relative '../test_helper'

class FixtureTest < ActiveSupport::TestCase
  
  def test_import_all
    Cms::Page.destroy_all
    Cms::Layout.destroy_all
    Cms::Snippet.destroy_all
    
    assert_difference 'Cms::Layout.count', 2 do
      assert_difference 'Cms::Page.count', 2 do
        assert_difference 'Cms::Snippet.count', 1 do
          ComfortableMexicanSofa::Fixture::Importer.new('sample-site', 'default-site').import!
        end
      end
    end
  end
  
  def test_import_all_with_no_site
    cms_sites(:default).destroy
    
    assert_exception_raised ActiveRecord::RecordNotFound do
      ComfortableMexicanSofa::Fixture::Importer.new('sample-site', 'default-site').import!
    end
  end
  
  def test_export_all
    host_path = File.join(ComfortableMexicanSofa.config.fixtures_path, 'test-site')
    ComfortableMexicanSofa::Fixture::Exporter.new('default-site', 'test-site').export!
    FileUtils.rm_rf(host_path)
  end
  
  def test_import_all_with_no_site
    cms_sites(:default).destroy
    
    assert_exception_raised ActiveRecord::RecordNotFound do
      ComfortableMexicanSofa::Fixture::Exporter.new('sample-site', 'default-site').export!
    end
  end
  
end