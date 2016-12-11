require_relative '../test_helper'

class CmsLayoutTest < ActiveSupport::TestCase
  
  def test_fixtures_validity
    Comfy::Cms::Layout.all.each do |layout|
      assert layout.valid?, layout.errors.full_messages.to_s
    end
  end
  
  def test_validations
    layout = comfy_cms_sites(:default).layouts.create
    assert layout.errors.present?
    assert_has_errors_on layout, [:label, :identifier]
  end
  
  def test_label_assignment
    layout = comfy_cms_sites(:default).layouts.new(
      :identifier => 'test',
      :content    => '{{cms:page:content}}'
    )
    assert layout.valid?
    assert_equal 'Test', layout.label
  end
  
  def test_creation
    assert_difference 'Comfy::Cms::Layout.count' do
      layout = comfy_cms_sites(:default).layouts.create(
        :label      => 'New Layout',
        :identifier => 'new-layout',
        :content    => '{{cms:page:content}}',
        :css        => 'css',
        :js         => 'js'
      )
      assert_equal 'New Layout', layout.label
      assert_equal 'new-layout', layout.identifier
      assert_equal '{{cms:page:content}}', layout.content
      assert_equal 'css', layout.css
      assert_equal 'js', layout.js
      assert_equal 1, layout.position
    end
  end
  
  def test_options_for_select
    assert_equal ['Default Layout', 'Nested Layout', '. . Child Layout'],
      Comfy::Cms::Layout.options_for_select(comfy_cms_sites(:default)).collect{|t| t.first}
    assert_equal ['Default Layout', 'Nested Layout'],
      Comfy::Cms::Layout.options_for_select(comfy_cms_sites(:default), comfy_cms_layouts(:child)).collect{|t| t.first}
    assert_equal ['Default Layout'],
      Comfy::Cms::Layout.options_for_select(comfy_cms_sites(:default), comfy_cms_layouts(:nested)).collect{|t| t.first}
  end
  
  def test_app_layouts_for_select
    FileUtils.touch(File.expand_path('app/views/layouts/comfy/admin/cms/nested.html.erb', Rails.root))
    FileUtils.touch(File.expand_path('app/views/layouts/comfy/_partial.html.erb', Rails.root))
    FileUtils.touch(File.expand_path('app/views/layouts/comfy/not_a_layout.erb', Rails.root))

    view_paths = [File.expand_path('app/views/', Rails.root)]
    assert_equal ['comfy/admin/cms', 'comfy/admin/cms/nested'], Comfy::Cms::Layout.app_layouts_for_select(view_paths)
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
  
  def test_merged_content_with_same_child_content
    parent_layout = comfy_cms_layouts(:nested)
    assert_equal "{{cms:page:header}}\n{{cms:page:content}}", parent_layout.content
    assert_equal "{{cms:page:header}}\n{{cms:page:content}}", parent_layout.merged_content
    
    child_layout = comfy_cms_layouts(:child)
    assert_equal parent_layout, child_layout.parent
    assert_equal "{{cms:page:left_column}}\n{{cms:page:right_column}}", child_layout.content
    assert_equal "{{cms:page:header}}\n{{cms:page:left_column}}\n{{cms:page:right_column}}", child_layout.merged_content
    
    child_layout.update_columns(:content => '{{cms:page:content}}')
    assert_equal "{{cms:page:header}}\n{{cms:page:content}}", child_layout.merged_content
    
    parent_layout.update_columns(:content => '{{cms:page:whatever}}')
    child_layout.reload
    assert_equal '{{cms:page:content}}', child_layout.merged_content
  end
  
  def test_update_forces_page_content_reload
    layout_1 = comfy_cms_layouts(:nested)
    layout_2 = comfy_cms_layouts(:child)
    page_1 = comfy_cms_sites(:default).pages.create!(
      :label        => 'page_1',
      :slug         => 'page-1',
      :parent_id    => comfy_cms_pages(:default).id,
      :layout_id    => layout_1.id,
      :is_published => '1',
      :blocks_attributes => [
        { :identifier => 'header',
          :content    => 'header_content' },
        { :identifier => 'content',
          :content    => 'content_content' }
      ]
    )
    page_2 = comfy_cms_sites(:default).pages.create!(
      :label          => 'page_2',
      :slug           => 'page-2',
      :parent_id      => comfy_cms_pages(:default).id,
      :layout_id      => layout_2.id,
      :is_published   => '1',
      :blocks_attributes => [
        { :identifier => 'header',
          :content    => 'header_content' },
        { :identifier => 'left_column',
          :content    => 'left_column_content' },
        { :identifier => 'right_column',
          :content    => 'left_column_content' }
      ]
    )
    assert_equal "header_content\ncontent_content", page_1.content_cache
    assert_equal "header_content\nleft_column_content\nleft_column_content", page_2.content_cache
    
    layout_1.update_attributes(:content => "Updated {{cms:page:content}}")
    page_1.reload
    page_2.reload
    
    assert_equal "Updated content_content", page_1.content_cache
    assert_equal "Updated left_column_content\nleft_column_content", page_2.content_cache
  end

  def test_cache_buster
    timestamp = Time.current
    layout = comfy_cms_sites(:default).layouts.create(updated_at: timestamp)

    assert_equal timestamp.to_i, layout.cache_buster
  end
end
