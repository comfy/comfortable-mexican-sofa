# encoding: utf-8

require_relative '../../../test_helper'

class FixtureSnippetExporterTest < ActiveSupport::TestCase
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
