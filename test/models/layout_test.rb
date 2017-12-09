require_relative '../test_helper'

class CmsLayoutTest < ActiveSupport::TestCase

  setup do
    @site   = comfy_cms_sites(:default)
    @layout = comfy_cms_layouts(:default)
    @page   = comfy_cms_pages(:default)
  end

  def test_fixtures_validity
    Comfy::Cms::Layout.all.each do |layout|
      assert layout.valid?, layout.errors.full_messages.to_s
    end
  end

  def test_validations
    layout = @site.layouts.create
    assert layout.errors.present?
    assert_has_errors_on layout, [:label, :identifier]
  end

  def test_content_tokens
    layout = Comfy::Cms::Layout.new(content: "a {{cms:text content}} b")
    assert_equal ["a ", {tag_class: "text", tag_params: "content"}, " b"],
      layout.content_tokens
  end

  def test_content_tokens_nested
    layout_a = Comfy::Cms::Layout.new(content: "a {{cms:text content}} {{cms:text footer}} b")
    layout_b = Comfy::Cms::Layout.new(content: "c {{cms:text content}} d")
    layout_b.parent = layout_a
    assert_equal [
      "a ", "c ", {tag_class: "text", tag_params: "content"}, " d", " ",
      {tag_class: "text", tag_params: "footer"}, " b"
    ], layout_b.content_tokens
  end

  def test_content_tokens_nested_with_fragment_subclass_tag
    layout_a = Comfy::Cms::Layout.new(content: "a {{cms:markdown content}} b")
    layout_b = Comfy::Cms::Layout.new(content: "c {{cms:text content}} d")
    layout_b.parent = layout_a
    assert_equal [
      "a ", "c ", {tag_class: "text", tag_params: "content"}, " d", " b"
    ], layout_b.content_tokens
  end

  def test_content_tokens_nested_with_non_fragment_subclass_tag
    layout_a = Comfy::Cms::Layout.new(content: "a {{cms:snippet content}} b")
    layout_b = Comfy::Cms::Layout.new(content: "c {{cms:text content}} d")
    layout_b.parent = layout_a
    assert_equal [
      "c ", {tag_class: "text", tag_params: "content"}, " d"
    ], layout_b.content_tokens
  end

  def test_content_tokens_nested_without_content_tag
    layout_a = Comfy::Cms::Layout.new(content: "a {{cms:text footer}} b")
    layout_b = Comfy::Cms::Layout.new(content: "c {{cms:text content}} d")
    layout_b.parent = layout_a
    assert_equal ["c ", {tag_class: "text", tag_params: "content"}, " d"],
      layout_b.content_tokens
  end

  def test_label_assignment
    layout = @site.layouts.new(
      identifier: 'test',
      content:    'content'
    )
    assert layout.valid?
    assert_equal 'Test', layout.label
  end

  def test_creation
    assert_difference 'Comfy::Cms::Layout.count' do
      layout = @site.layouts.create(
        label:      'New Layout',
        identifier: 'new-layout',
        content:    '{{cms:text default}}',
        css:        'css',
        js:         'js'
      )
      assert_equal 'New Layout',            layout.label
      assert_equal 'new-layout',            layout.identifier
      assert_equal '{{cms:text default}}',  layout.content
      assert_equal 'css',                   layout.css
      assert_equal 'js',                    layout.js
      assert_equal 1,                       layout.position
    end
  end

  def test_options_for_select
    assert_equal ['Default Layout', 'Nested Layout', '. . Child Layout'],
      Comfy::Cms::Layout.options_for_select(@site).collect(&:first)
    assert_equal ['Default Layout', 'Nested Layout'],
      Comfy::Cms::Layout.options_for_select(@site, comfy_cms_layouts(:child)).collect(&:first)
    assert_equal ['Default Layout'],
      Comfy::Cms::Layout.options_for_select(@site, comfy_cms_layouts(:nested)).collect(&:first)
  end

  def test_app_layouts_for_select
    FileUtils.touch(File.expand_path('app/views/layouts/comfy/admin/cms/nested.html.erb', Rails.root))
    FileUtils.touch(File.expand_path('app/views/layouts/comfy/_partial.html.erb', Rails.root))
    FileUtils.touch(File.expand_path('app/views/layouts/comfy/not_a_layout.erb', Rails.root))

    view_paths = [File.expand_path('app/views/', Rails.root)]
    assert_equal ['comfy/admin/cms', 'comfy/admin/cms/nested'],
      Comfy::Cms::Layout.app_layouts_for_select(view_paths)

  ensure
    FileUtils.rm(File.expand_path('app/views/layouts/comfy/admin/cms/nested.html.erb', Rails.root))
    FileUtils.rm(File.expand_path('app/views/layouts/comfy/_partial.html.erb', Rails.root))
    FileUtils.rm(File.expand_path('app/views/layouts/comfy/not_a_layout.erb', Rails.root))
  end

  def test_multiple_view_paths
    FileUtils.mkdir_p(File.expand_path('app/additional_views/layouts', Rails.root))
    FileUtils.touch(File.expand_path('app/additional_views/layouts/additional_layout.html.erb', Rails.root))

    view_paths = [File.expand_path('app/views/', Rails.root), File.expand_path('app/additional_views', Rails.root)]
    assert_equal ['additional_layout', 'comfy/admin/cms'], Comfy::Cms::Layout.app_layouts_for_select(view_paths)
  ensure
    FileUtils.rm_r(File.expand_path('app/additional_views', Rails.root))
  end

  def test_update_forces_page_content_reload
    layout_1 = comfy_cms_layouts(:nested)
    layout_2 = comfy_cms_layouts(:child)
    page_1 = @site.pages.create!(
      label:        'page_1',
      slug:         'page-1',
      parent_id:    @page.id,
      layout_id:    layout_1.id,
      is_published: '1',
      fragments_attributes: [
        { identifier: 'header',
          content:    'header_content' },
        { identifier: 'content',
          content:    'content_content' }
      ]
    )
    page_2 = @site.pages.create!(
      label:          'page_2',
      slug:           'page-2',
      parent_id:      @page.id,
      layout_id:      layout_2.id,
      is_published:   '1',
      fragments_attributes: [
        { identifier: 'header',
          content:    'header_content' },
        { identifier: 'left_column',
          content:    'left_column_content' },
        { identifier: 'right_column',
          content:    'left_column_content' }
      ]
    )
    assert_equal "header_content\ncontent_content", page_1.content_cache
    assert_equal "header_content\nleft_column_content\nleft_column_content", page_2.content_cache

    layout_1.update_attributes(content: "Updated {{cms:text content}}")
    page_1.reload
    page_2.reload

    assert_equal "Updated content_content", page_1.content_cache
    assert_equal "Updated left_column_content\nleft_column_content", page_2.content_cache
  end

  def test_cache_buster
    timestamp = Time.current
    layout = @site.layouts.create(updated_at: timestamp)
    assert_equal timestamp.to_i, layout.cache_buster
  end
end
