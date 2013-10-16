require_relative '../test_helper'

class CmsLayoutTest < ActiveSupport::TestCase
  
  def test_fixtures_validity
    Cms::Layout.all.each do |layout|
      assert layout.valid?, layout.errors.full_messages.to_s
    end
  end
  
  def test_validations
    layout = cms_sites(:default).layouts.create
    assert layout.errors.present?
    assert_has_errors_on layout, [:label, :identifier]
  end
  
  def test_label_assignment
    layout = cms_sites(:default).layouts.new(
      :identifier => 'test',
      :content    => '{{cms:page:content}}'
    )
    assert layout.valid?
    assert_equal 'Test', layout.label
  end
  
  def test_creation
    assert_difference 'Cms::Layout.count' do
      layout = cms_sites(:default).layouts.create(
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
      Cms::Layout.options_for_select(cms_sites(:default)).collect{|t| t.first}
    assert_equal ['Default Layout', 'Nested Layout'],
      Cms::Layout.options_for_select(cms_sites(:default), cms_layouts(:child)).collect{|t| t.first}
    assert_equal ['Default Layout'],
      Cms::Layout.options_for_select(cms_sites(:default), cms_layouts(:nested)).collect{|t| t.first}
  end
  
  def test_app_layouts_for_select
    FileUtils.touch(File.expand_path('app/views/layouts/admin/cms/nested.html.erb', Rails.root))
    FileUtils.touch(File.expand_path('app/views/layouts/_partial.html.erb', Rails.root))
    FileUtils.touch(File.expand_path('app/views/layouts/not_a_layout.erb', Rails.root))
    
    assert_equal ['admin/cms', 'admin/cms/nested'], Cms::Layout.app_layouts_for_select
    
    FileUtils.rm(File.expand_path('app/views/layouts/admin/cms/nested.html.erb', Rails.root))
    FileUtils.rm(File.expand_path('app/views/layouts/_partial.html.erb', Rails.root))
    FileUtils.rm(File.expand_path('app/views/layouts/not_a_layout.erb', Rails.root))
  end
  
  def test_merged_content_with_same_child_content
    parent_layout = cms_layouts(:nested)
    assert_equal "{{cms:page:header}}\n{{cms:page:content}}", parent_layout.content
    assert_equal "{{cms:page:header}}\n{{cms:page:content}}", parent_layout.merged_content
    
    child_layout = cms_layouts(:child)
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
    layout_1 = cms_layouts(:nested)
    layout_2 = cms_layouts(:child)
    page_1 = cms_sites(:default).pages.create!(
      :label        => 'page_1',
      :slug         => 'page-1',
      :parent_id    => cms_pages(:default).id,
      :layout_id    => layout_1.id,
      :is_published => '1',
      :blocks_attributes => [
        { :identifier => 'header',
          :content    => 'header_content' },
        { :identifier => 'content',
          :content    => 'content_content' }
      ]
    )
    page_2 = cms_sites(:default).pages.create!(
      :label          => 'page_2',
      :slug           => 'page-2',
      :parent_id      => cms_pages(:default).id,
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
    assert_equal "header_content\ncontent_content", page_1.content
    assert_equal "header_content\nleft_column_content\nleft_column_content", page_2.content
    
    layout_1.update_attributes(:content => "Updated {{cms:page:content}}")
    page_1.reload
    page_2.reload
    
    assert_equal "Updated content_content", page_1.content
    assert_equal "Updated left_column_content\nleft_column_content", page_2.content
  end
  
end
