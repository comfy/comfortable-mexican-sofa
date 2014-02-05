# encoding: utf-8
require_relative '../../../test_helper'

class FixturePageExporterTest < ActiveSupport::TestCase
  def test_export
    cms_pages(:default).update_attribute(:target_page, cms_pages(:child))
    cms_categories(:default).categorizations.create!(
      :categorized => cms_pages(:default)
    )

    host_path = File.join(ComfortableMexicanSofa.config.fixtures_path, 'test-site')
    page_1_attr_path    = File.join(host_path, 'pages/index/attributes.yml')
    page_1_block_a_path = File.join(host_path, 'pages/index/default_field_text.html')
    page_1_block_b_path = File.join(host_path, 'pages/index/default_page_text.html')
    page_2_attr_path    = File.join(host_path, 'pages/index/child-page/attributes.yml')

    ComfortableMexicanSofa::Fixture::Page::Exporter.new('default-site', 'test-site').export!

    assert_equal ({
      'label'         => 'Default Page',
      'layout'        => 'default',
      'parent'        => nil,
      'target_page'   => '/child-page',
      'categories'    => ['Default'],
      'is_published'  => true,
      'position'      => 0
    }), YAML.load_file(page_1_attr_path)
    assert_equal cms_blocks(:default_field_text).content, IO.read(page_1_block_a_path)
    assert_equal cms_blocks(:default_page_text).content, IO.read(page_1_block_b_path)

    assert_equal ({
      'label'         => 'Child Page',
      'layout'        => 'default',
      'parent'        => 'index',
      'target_page'   => nil,
      'categories'    => [],
      'is_published'  => true,
      'position'      => 0
    }), YAML.load_file(page_2_attr_path)

    FileUtils.rm_rf(host_path)
  end
end
