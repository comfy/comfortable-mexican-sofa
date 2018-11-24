# frozen_string_literal: true

require_relative "../test_helper"

class SeedsTest < ActiveSupport::TestCase

  def test_import_all
    Comfy::Cms::Page.destroy_all
    Comfy::Cms::Layout.destroy_all
    Comfy::Cms::Snippet.destroy_all

    assert_difference(-> { Comfy::Cms::Layout.count }, 2) do
      assert_difference(-> { Comfy::Cms::Page.count }, 3) do
        assert_difference(-> { Comfy::Cms::Snippet.count }, 1) do
          ComfortableMexicanSofa::Seeds::Importer.new("sample-site", "default-site").import!
        end
      end
    end
  end

  def test_import_all_with_no_site
    comfy_cms_sites(:default).destroy

    assert_exception_raised ActiveRecord::RecordNotFound do
      ComfortableMexicanSofa::Seeds::Importer.new("sample-site", "default-site").import!
    end
  end

  def test_import_single_class
    Comfy::Cms::Page.destroy_all
    Comfy::Cms::Layout.destroy_all
    Comfy::Cms::Snippet.destroy_all

    assert_difference(-> { Comfy::Cms::Layout.count }, 2) do
      assert_difference(-> { Comfy::Cms::Page.count }, 0) do
        assert_difference(-> { Comfy::Cms::Snippet.count }, 0) do
          ComfortableMexicanSofa::Seeds::Importer.new("sample-site", "default-site").import!(["Layout"])
        end
      end
    end
  end

  def test_import_multiple_classes
    Comfy::Cms::Page.destroy_all
    Comfy::Cms::Layout.destroy_all
    Comfy::Cms::Snippet.destroy_all

    assert_difference(-> { Comfy::Cms::Layout.count }, 2) do
      assert_difference(-> { Comfy::Cms::Page.count }, 0) do
        assert_difference(-> { Comfy::Cms::Snippet.count }, 1) do
          ComfortableMexicanSofa::Seeds::Importer.new("sample-site", "default-site").import!(%w[Layout Snippet])
        end
      end
    end
  end

  def test_import_all_with_no_folder
    assert_exception_raised ComfortableMexicanSofa::Seeds::Error do
      ComfortableMexicanSofa::Seeds::Importer.new("invalid", "default-site").import!
    end
  end

  def test_export_all
    ActiveStorage::Blob.any_instance.stubs(:download).returns(
      File.read(File.join(Rails.root, "db/cms_seeds/sample-site/files/default.jpg"))
    )

    host_path = File.join(ComfortableMexicanSofa.config.seeds_path, "test-site")
    ComfortableMexicanSofa::Seeds::Exporter.new("default-site", "test-site").export!
  ensure
    FileUtils.rm_rf(host_path)
  end

  def test_export_all_with_no_site
    comfy_cms_sites(:default).destroy

    assert_exception_raised ActiveRecord::RecordNotFound do
      ComfortableMexicanSofa::Seeds::Exporter.new("sample-site", "default-site").export!
    end
  end

  def test_export_single_class
    host_path = File.join(ComfortableMexicanSofa.config.seeds_path, "test-site")
    ComfortableMexicanSofa::Seeds::Exporter.new("default-site", "test-site").export!(["Layout"])
    assert(File.exist?(File.join(host_path, "layouts")))
  ensure
    FileUtils.rm_rf(host_path)
  end

  def test_export_multiple_classes
    host_path = File.join(ComfortableMexicanSofa.config.seeds_path, "test-site")
    ComfortableMexicanSofa::Seeds::Exporter.new("default-site", "test-site").export!(%w[Layout Snippet])
    assert(%w[layouts snippets].all? { |klass| File.exist?(File.join(host_path, klass)) })
  ensure
    FileUtils.rm_rf(host_path)
  end

end
