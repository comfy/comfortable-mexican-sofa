require_relative '../test_helper'

class SeedsTest < ActiveSupport::TestCase

  def test_import_all
    Comfy::Cms::Page.destroy_all
    Comfy::Cms::Layout.destroy_all
    Comfy::Cms::Snippet.destroy_all

    assert_count_difference [Comfy::Cms::Layout], 2 do
      assert_count_difference [Comfy::Cms::Page], 3 do
        assert_count_difference [Comfy::Cms::Snippet], 1 do
          ComfortableMexicanSofa::Seeds::Importer.new('sample-site', 'default-site').import!
        end
      end
    end
  end

  def test_import_all_with_no_site
    comfy_cms_sites(:default).destroy

    assert_exception_raised ActiveRecord::RecordNotFound do
      ComfortableMexicanSofa::Seeds::Importer.new('sample-site', 'default-site').import!
    end
  end

  def test_export_all
    ActiveStorage::Blob.any_instance.stubs(:download).returns(
      File.read(File.join(Rails.root, 'db/cms_seeds/sample-site/files/default.jpg'))
    )

    host_path = File.join(ComfortableMexicanSofa.config.seeds_path, 'test-site')
    ComfortableMexicanSofa::Seeds::Exporter.new('default-site', 'test-site').export!
    FileUtils.rm_rf(host_path)
  end

  def test_export_all_with_no_site
    comfy_cms_sites(:default).destroy

    assert_exception_raised ActiveRecord::RecordNotFound do
      ComfortableMexicanSofa::Seeds::Exporter.new('sample-site', 'default-site').export!
    end
  end
end
