require 'test_helper'

class ComfortableMexicanSofa::FormBuilderTest < ActionView::TestCase
  include ComfortableMexicanSofa::ViewMethods

  setup :setup_cms_page

  def setup_cms_page
    @cms_page = Cms::Page.new
  end

  def cms_admin_page_path(*args)
    '/cms-admin/pages'
  end
  alias :cms_admin_pages_path :cms_admin_page_path

  def with_concat_form_for(object, &block)
    concat cms_form_for(object, :url => cms_admin_page_path, &block)
  end

  def with_form_for(object, *args, &block)
    with_concat_form_for(object) do |f|
      f.text_field(*args) + (block.call(f) if block_given?)
    end
  end

  test "labels for inputs with custom id should reference the input correctly" do
    with_form_for(@cms_page, :label, :id => 'slugify')
    assert_no_select 'label#slugify'
    assert_select 'label[for="slugify"]', 'Label'
    assert_select "input#slugify[name='cms_page[label]']"
  end

  test "label_for method returns html_safe strings" do
    cms_form_for @cms_page, :url => cms_admin_pages_path do |f|
      assert f.label_for(:is_published).html_safe?, "must be html_safe string"
    end
  end

  test "the label options are not passed to the input element" do
    with_form_for(@cms_page, :label)
    assert_no_select 'input[for="cms_page_label"]'
  end

  test "the label text is automatically translated" do
    with_translations :test_lang, {
      :attributes => { :slug => "Gulsty" },
      :activerecord => { :attributes => { :'cms/page' => { :label => 'Titlumtimpin' } } }
    } do
      with_form_for(@cms_page, :label) do |f|
        f.text_field(:slug) +
          f.text_field(:parent_id)
      end
      assert_select 'label[for="cms_page_label"]',     'Titlumtimpin', 'using model specific attribute names'
      assert_select 'label[for="cms_page_slug"]',      'Gulsty',       'using common attribute names'
      assert_select 'label[for="cms_page_parent_id"]', 'Parent',       'using default humanized attribute name'
    end
  end

  test "the label text is titleized" do
    with_translations :test_lang, :attributes => { :label => "two words" } do
      with_form_for(@cms_page, :label)
      assert_select 'label[for="cms_page_label"]', "Two Words", "Label is titleized"
    end
  end

  test "the label can be hard coded" do
    with_form_for(@cms_page, :slug, :label => "Custom Path")
    assert_select 'label[for="cms_page_slug"]', "Custom Path"
  end

  test "basic form builder features" do
    with_form_for(@cms_page, :label) do |f|
      f.text_field(:slug) +
      f.select(:parent_id, [['1', 'Parent']])
    end
    assert_select 'form' do
      assert_select 'div.form_element.text_field_element' do
        assert_select 'label[for="cms_page_label"]', 'Label'
        assert_select 'input#cms_page_label'
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
end
