require File.expand_path('../test_helper', File.dirname(__FILE__))

class FormBuilderTest < ActionView::TestCase
  include ComfortableMexicanSofa::ViewMethods
  
  def test_form_render_basic
    concat( comfy_form_for(cms_pages(:child), :url => '#') do |f|
      f.text_area(:label) +
      f.text_field(:slug) +
      f.select(:parent_id, [['1', 'Parent']])
    end )
    
    assert_select 'form' do
      assert_select 'div.form_element.text_area_element' do
        assert_select 'label[for="cms_page_label"]', 'Label'
        assert_select 'textarea#cms_page_label'
      end
      assert_select 'div.form_element.text_field_element' do
        assert_select 'label[for="cms_page_slug"]', 'Slug'
        assert_select 'input#cms_page_slug'
      end
      assert_select 'div.form_element.select_element' do
        assert_select 'select#cms_page_parent_id'
        assert_select 'label', 'Parent'
      end
    end
  end
  
  def test_form_render_with_custom_ids
    concat( comfy_form_for(cms_pages(:child), :url => '#') do |f|
      f.text_field(:label, :id => 'slugify') +
      f.text_field(:slug)
    end )
    
    assert_no_select 'label#slugify'
    assert_select 'label[for="slugify"]', 'Label'
    assert_select "input#slugify[name='cms_page[label]']"
  end
  
  def test_form_label_with_html_safe_labels
    comfy_form_for(cms_pages(:child), :url => '#') do |f|
      assert f.label_for(:is_published).html_safe?
    end
  end
  
  def test_form_label_custom_override
    concat( comfy_form_for(cms_pages(:child), :url => '#') do |f|
      f.text_field(:slug, :label => 'Custom')
    end )
    assert_select 'label[for="cms_page_slug"]', 'Custom'
  end
  
  def test_form_label_translations
    with_translations :test_lang, {
      :attributes => { :slug => "Gulsty" },
      :activerecord => { :attributes => { :'cms/page' => { :label => 'Titlumtimpin' } } }
    } do
      concat( comfy_form_for(cms_pages(:child), :url => '#') do |f|
        f.text_field(:label) +
        f.text_field(:slug) +
        f.text_field(:parent_id)
      end )
      assert_select 'label[for="cms_page_label"]',     'Titlumtimpin'
      assert_select 'label[for="cms_page_slug"]',      'Gulsty'
      assert_select 'label[for="cms_page_parent_id"]', 'Parent'
    end
  end
  
end
