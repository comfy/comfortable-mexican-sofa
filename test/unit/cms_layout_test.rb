require File.expand_path('../test_helper', File.dirname(__FILE__))

class CmsLayoutTest < ActiveSupport::TestCase
  
  def test_fixtures_validity
    CmsLayout.all.each do |layout|
      assert layout.valid?
    end
  end
  
  def test_validations
    layout = CmsLayout.create
    assert layout.errors.present?
    assert_has_errors_on layout, [:label, :slug, :content]
  end
  
  def test_validation_of_tag_presence
    layout = CmsLayout.create(:content => 'some text')
    assert_has_errors_on layout, :content
    
    layout = CmsLayout.create(:content => '{cms:snippet:blah}')
    assert_has_errors_on layout, :content
    
    layout = cms_sites(:default).cms_layouts.new(
      :label    => 'test',
      :slug     => 'test',
      :content  => '{{cms:page:blah}}'
    )
    assert layout.valid?
    
    layout = cms_sites(:default).cms_layouts.new(
      :label    => 'test',
      :slug     => 'test',
      :content  => '{{cms:field:blah}}'
    )
    assert layout.valid?
  end
  
  def test_creation
    assert_difference 'CmsLayout.count' do
      layout = cms_sites(:default).cms_layouts.create(
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
      CmsLayout.options_for_select(cms_sites(:default)).collect{|t| t.first}
    assert_equal ['Default Layout', 'Nested Layout'],
      CmsLayout.options_for_select(cms_sites(:default), cms_layouts(:child)).collect{|t| t.first}
    assert_equal ['Default Layout'],
      CmsLayout.options_for_select(cms_sites(:default), cms_layouts(:nested)).collect{|t| t.first}
  end
  
  def test_app_layouts_for_select
    assert_equal ['cms_admin.html.erb'], CmsLayout.app_layouts_for_select
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
  
  def test_merged_css
    assert_equal "nested_css\nchild_css", cms_layouts(:child).merged_css
  end
  
  def test_merged_js
    assert_equal "nested_js\nchild_js", cms_layouts(:child).merged_js
  end
  
  def test_load_from_file
    assert !CmsLayout.load_from_file(cms_sites(:default), 'default')
    
    ComfortableMexicanSofa.configuration.seed_data_path = File.expand_path('../cms_seeds', File.dirname(__FILE__))
    
    assert !CmsLayout.load_from_file(cms_sites(:default), 'bogus')
    
    assert layout = CmsLayout.load_from_file(cms_sites(:default), 'default')
    assert_equal 'Default Layout', layout.label
    assert_equal '<html>{{cms:page:content}}</html>', layout.content
    
    assert layout = CmsLayout.load_from_file(cms_sites(:default), 'nested')
    assert_equal 'Nested Layout', layout.label
    assert_equal '<div>{{cms:page:content}}</div>', layout.content
    assert_equal '<html><div>{{cms:page:content}}</div></html>', layout.merged_content
  end
  
  def test_load_from_file_broken
    ComfortableMexicanSofa.configuration.seed_data_path = File.expand_path('../cms_seeds', File.dirname(__FILE__))
    error_message = "Failed to load from #{ComfortableMexicanSofa.configuration.seed_data_path}/test.host/layouts/broken.yml"
    assert_exception_raised RuntimeError, error_message do
      CmsLayout.load_from_file(cms_sites(:default), 'broken')
    end
  end
  
  def test_load_for_slug
    assert layout = CmsLayout.load_for_slug!(cms_sites(:default), 'default')
    assert !layout.new_record?
    db_content = layout.content
    
    ComfortableMexicanSofa.configuration.seed_data_path = File.expand_path('../cms_seeds', File.dirname(__FILE__))
    assert layout = CmsLayout.load_for_slug!(cms_sites(:default), 'default')
    assert layout.new_record?
    file_content = layout.content
    assert_not_equal db_content, file_content
  end
  
  def test_load_for_slug_exceptions
    assert_exception_raised ActiveRecord::RecordNotFound, 'CmsLayout with slug: not_found cannot be found' do
      CmsLayout.load_for_slug!(cms_sites(:default), 'not_found')
    end
    assert !CmsLayout.load_for_slug(cms_sites(:default), 'not_found')
    
    ComfortableMexicanSofa.configuration.seed_data_path = File.expand_path('../cms_seeds', File.dirname(__FILE__))
    assert_exception_raised ActiveRecord::RecordNotFound, 'CmsLayout with slug: not_found cannot be found' do
      CmsLayout.load_for_slug!(cms_sites(:default), 'not_found')
    end
    assert !CmsLayout.load_for_slug(cms_sites(:default), 'not_found')
  end
  
  def test_update_forces_page_content_reload
    layout = cms_layouts(:default)
    page = cms_pages(:default)
    assert_equal layout, page.cms_layout
    layout.update_attribute(:content, 'updated {{cms:page:default_page_text:text}} updated')
    page.reload
    assert_equal "updated default_page_text_content_a\ndefault_snippet_content\ndefault_page_text_content_b updated", page.content
  end
  
end
