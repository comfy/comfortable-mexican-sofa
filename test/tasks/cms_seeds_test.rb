# frozen_string_literal: true

require_relative "../test_helper"
require "rake"

class CmsSeedsTaskTest < ActiveSupport::TestCase

  setup do
    @rake = Rake::Application.new
    Rake.application = @rake
    # We force rake file reload by passing empty array as the last parameter
    Rake.application.rake_require("tasks/cms_seeds", $LOAD_PATH, [])
    Rake::Task.define_task(:environment)
  end

  def test_import
    importer = mock
    ComfortableMexicanSofa::Seeds::Importer.expects(:new).with("from_folder", "to_site").returns(importer)
    importer.expects(:import!)

    with_captured_stout do
      @rake["comfy:cms_seeds:import"].invoke("from_folder", "to_site")
    end
  end

  def test_import_for_a_specific_class
    importer = mock
    ComfortableMexicanSofa::Seeds::Importer.expects(:new).with("from_folder", "to_site").returns(importer)
    importer.expects(:import!).with(["Page"])

    with_captured_stout do
      @rake["comfy:cms_seeds:import"].invoke("from_folder", "to_site", "Page")
    end
  end

  def test_export
    exporter = mock
    ComfortableMexicanSofa::Seeds::Exporter.expects(:new).with("from_site", "to_folder").returns(exporter)
    exporter.expects(:export!)

    with_captured_stout do
      @rake["comfy:cms_seeds:export"].invoke("from_site", "to_folder")
    end
  end

  def test_export_for_a_specific_class
    exporter = mock
    ComfortableMexicanSofa::Seeds::Exporter.expects(:new).with("from_site", "to_folder").returns(exporter)
    exporter.expects(:export!).with(["Page"])

    with_captured_stout do
      @rake["comfy:cms_seeds:export"].invoke("from_site", "to_folder", "Page")
    end
  end

end
