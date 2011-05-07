require File.expand_path('../../test_helper', File.dirname(__FILE__))

class CmsLayoutTest < ActiveSupport::TestCase
  
  def test_fixtures_validity
    Cms::Layout.all.each do |layout|
      assert layout.valid?, layout.errors.full_messages.to_s
    end
  end
  
  def test_validations
    layout = cms_sites(:default).layouts.create
    assert layout.errors.present?
    assert_has_errors_on layout, [:label, :slug, :content]
  end
  
  def test_validation_of_tag_presence
    layout = cms_sites(:default).layouts.create(:content => 'some text')
    assert_has_errors_on layout, :content
    
    layout = cms_sites(:default).layouts.create(:content => '{cms:snippet:blah}')
    assert_has_errors_on layout, :content
    
    layout = cms_sites(:default).layouts.new(
      :label    => 'test',
      :slug     => 'test',
      :content  => '{{cms:page:blah}}'
    )
    assert layout.valid?
    
    layout = cms_sites(:default).layouts.new(
      :label    => 'test',
      :slug     => 'test',
      :content  => '{{cms:field:blah}}'
    )
    assert layout.valid?
  end
  
  def test_creation
    assert_difference 'Cms::Layout.count' do
      layout = cms_sites(:default).layouts.create(
        :label    => 'New Layout',
        :slug     => 'new-layout',
        :content  => '{{cms:page:content}}',
        :css      => 'css',
        :js       => 'js'
      )
      assert_equal 'New Layout', layout.label
      assert_equal 'new-layout', layout.slug
      assert_equal '{{cms:page:content}}', layout.content
      assert_equal 'css', layout.css
      assert_equal 'js', layout.js
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
    assert_equal ['cms_admin.html.erb'], Cms::Layout.app_layouts_for_select
  end
  
  def test_merged_content_with_same_child_content
    parent_layout = cms_layouts(:nested)
    assert_equal "{{cms:page:header}}\n{{cms:page:content}}", parent_layout.content
    assert_equal "{{cms:page:header}}\n{{cms:page:content}}", parent_layout.merged_content
    
    child_layout = cms_layouts(:child)
    assert_equal parent_layout, child_layout.parent
    assert_equal "{{cms:page:left_column}}\n{{cms:page:right_column}}", child_layout.content
    assert_equal "{{cms:page:header}}\n{{cms:page:left_column}}\n{{cms:page:right_column}}", child_layout.merged_content
    
    child_layout.update_attribute(:content, '{{cms:page:content}}')
    assert_equal "{{cms:page:header}}\n{{cms:page:content}}", child_layout.merged_content
    
    parent_layout.update_attribute(:content, '{{cms:page:whatever}}')
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
        { :label    => 'header',
          :content  => 'header_content' },
        { :label    => 'content',
          :content  => 'content_content' }
      ]
    )
    page_2 = cms_sites(:default).pages.create!(
      :label          => 'page_2',
      :slug           => 'page-2',
      :parent_id      => cms_pages(:default).id,
      :layout_id      => layout_2.id,
      :is_published   => '1',
      :blocks_attributes => [
        { :label    => 'header',
          :content  => 'header_content' },
        { :label    => 'left_column',
          :content  => 'left_column_content' },
        { :label    => 'right_column',
          :content  => 'left_column_content' }
      ]
    )
    assert_equal "header_content\ncontent_content", page_1.content
    assert_equal "header_content\nleft_column_content\nleft_column_content", page_2.content
    
    layout_1.update_attribute(:content, "Updated {{cms:page:content}}")
    page_1.reload
    page_2.reload
    
    assert_equal "Updated content_content", page_1.content
    assert_equal "Updated left_column_content\nleft_column_content", page_2.content
  end
  
end
