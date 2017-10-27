require_relative '../../test_helper'

class SeedsLayoutsTest < ActiveSupport::TestCase

  DEFAULT_HTML = <<~HTML
    <html>
      <body>
        {{ cms:markdown content }}
      </body>
    </html>
  HTML

  NESTED_HTML = <<~HTML.strip
    {{ cms:file thumbnail }}
    <div class='left'>{{ cms:markdown left }}</div>
    <div class='right'>{{ cms:markdown right }}</div>
  HTML

  def test_creation
    Comfy::Cms::Layout.delete_all

    assert_difference 'Comfy::Cms::Layout.count', 2 do
      ComfortableMexicanSofa::Seeds::Layout::Importer.new('sample-site', 'default-site').import!

      assert layout = Comfy::Cms::Layout.where(identifier: "default").first
      assert_equal 'Default Fixture Layout', layout.label
      assert_equal DEFAULT_HTML, layout.content
      assert_equal 'body{color: red}', layout.css
      assert_equal '// default js', layout.js

      assert nested_layout = Comfy::Cms::Layout.where(identifier: "nested").first
      assert_equal layout, nested_layout.parent
      assert_equal 'Default Fixture Nested Layout', nested_layout.label
      assert_equal NESTED_HTML, nested_layout.content
      assert_equal 'div{float:left}', nested_layout.css
      assert_equal '// nested js', nested_layout.js
    end
  end

  def test_update
    layout        = comfy_cms_layouts(:default)
    nested_layout = comfy_cms_layouts(:nested)
    child_layout  = comfy_cms_layouts(:child)
    layout.update_column(:updated_at, 10.years.ago)
    nested_layout.update_column(:updated_at, 10.years.ago)
    child_layout.update_column(:updated_at, 10.years.ago)

    assert_difference 'Comfy::Cms::Layout.count', -1 do
      ComfortableMexicanSofa::Seeds::Layout::Importer.new('sample-site', 'default-site').import!

      layout.reload
      assert_equal 'Default Fixture Layout', layout.label
      assert_equal DEFAULT_HTML, layout.content
      assert_equal 'body{color: red}', layout.css
      assert_equal '// default js', layout.js
      assert_equal 0, layout.position

      nested_layout.reload
      assert_equal layout, nested_layout.parent
      assert_equal 'Default Fixture Nested Layout', nested_layout.label
      assert_equal NESTED_HTML, nested_layout.content
      assert_equal 'div{float:left}', nested_layout.css
      assert_equal '// nested js', nested_layout.js
      assert_equal 42, nested_layout.position

      assert_nil Comfy::Cms::Layout.where(identifier: "child").first
    end
  end

  def test_update_ignore
    layout = comfy_cms_layouts(:default)
    layout_path       = File.join(ComfortableMexicanSofa.config.seeds_path, 'sample-site', 'layouts', 'default')
    attr_file_path    = File.join(layout_path, 'attributes.yml')
    content_file_path = File.join(layout_path, 'content.html')
    css_file_path     = File.join(layout_path, 'stylesheet.css')
    js_file_path      = File.join(layout_path, 'javascript.js')

    assert layout.updated_at >= File.mtime(attr_file_path)
    assert layout.updated_at >= File.mtime(content_file_path)
    assert layout.updated_at >= File.mtime(css_file_path)
    assert layout.updated_at >= File.mtime(js_file_path)

    ComfortableMexicanSofa::Seeds::Layout::Importer.new('sample-site', 'default-site').import!
    layout.reload
    assert_equal 'default',               layout.identifier
    assert_equal 'Default Layout',        layout.label
    assert_equal "{{cms:text content}}",  layout.content
    assert_equal 'default_css',           layout.css
    assert_equal 'default_js',            layout.js
  end

  def test_update_force
    layout = comfy_cms_layouts(:default)
    ComfortableMexicanSofa::Seeds::Layout::Importer.new('sample-site', 'default-site').import!
    layout.reload
    assert_equal 'Default Layout', layout.label

    ComfortableMexicanSofa::Seeds::Layout::Importer.new('sample-site', 'default-site', :forced).import!
    layout.reload
    assert_equal 'Default Fixture Layout', layout.label
  end

  def test_export
    host_path = File.join(ComfortableMexicanSofa.config.seeds_path, 'test-site')
    layout_1_attr_path    = File.join(host_path, 'layouts/nested/attributes.yml')
    layout_1_content_path = File.join(host_path, 'layouts/nested/content.html')
    layout_1_css_path     = File.join(host_path, 'layouts/nested/stylesheet.css')
    layout_1_js_path      = File.join(host_path, 'layouts/nested/javascript.js')
    layout_2_attr_path    = File.join(host_path, 'layouts/nested/child/attributes.yml')
    layout_2_content_path = File.join(host_path, 'layouts/nested/child/content.html')
    layout_2_css_path     = File.join(host_path, 'layouts/nested/child/stylesheet.css')
    layout_2_js_path      = File.join(host_path, 'layouts/nested/child/javascript.js')

    ComfortableMexicanSofa::Seeds::Layout::Exporter.new('default-site', 'test-site').export!

    assert File.exist?(layout_1_attr_path)
    assert File.exist?(layout_1_content_path)
    assert File.exist?(layout_1_css_path)
    assert File.exist?(layout_1_js_path)

    assert File.exist?(layout_2_attr_path)
    assert File.exist?(layout_2_content_path)
    assert File.exist?(layout_2_css_path)
    assert File.exist?(layout_2_js_path)

    assert_equal ({
      'label'       => 'Nested Layout',
      'app_layout'  => nil,
      'position'    => 0
    }), YAML.load_file(layout_1_attr_path)
    assert_equal comfy_cms_layouts(:nested).content, IO.read(layout_1_content_path)
    assert_equal comfy_cms_layouts(:nested).css, IO.read(layout_1_css_path)
    assert_equal comfy_cms_layouts(:nested).js, IO.read(layout_1_js_path)

    assert_equal ({
      'label'       => 'Child Layout',
      'app_layout'  => nil,
      'position'    => 0
    }), YAML.load_file(layout_2_attr_path)
    assert_equal comfy_cms_layouts(:child).content, IO.read(layout_2_content_path)
    assert_equal comfy_cms_layouts(:child).css, IO.read(layout_2_css_path)
    assert_equal comfy_cms_layouts(:child).js, IO.read(layout_2_js_path)

    FileUtils.rm_rf(host_path)
  end
end
