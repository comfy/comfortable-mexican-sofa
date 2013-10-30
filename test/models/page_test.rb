# encoding: utf-8

require_relative '../test_helper'

class CmsPageTest < ActiveSupport::TestCase
  
  def test_fixtures_validity
    Cms::Page.all.each do |page|
      assert page.valid?, page.errors.full_messages.to_s
      assert_equal page.content, page.render
    end
  end
  
  def test_validations
    page = Cms::Page.new
    page.save
    assert page.invalid?
    assert_has_errors_on page, :site_id, :layout, :slug, :label
  end
  
  def test_validation_of_parent_presence
    page = cms_sites(:default).pages.new(new_params)
    assert !page.parent
    assert page.valid?, page.errors.full_messages.to_s
    assert_equal cms_pages(:default), page.parent
  end
  
  def test_validation_of_parent_relationship
    page = cms_pages(:default)
    assert !page.parent
    page.parent = page
    assert page.invalid?
    assert_has_errors_on page, :parent_id
    page.parent = cms_pages(:child)
    assert page.invalid?
    assert_has_errors_on page, :parent_id
  end
  
  def test_validation_of_target_page
    page = cms_pages(:child)
    page.target_page = cms_pages(:default)
    page.save!
    assert_equal cms_pages(:default), page.target_page
    page.target_page = page
    assert page.invalid?
    assert_has_errors_on page, :target_page_id
  end
  
  def test_validation_of_slug
    page = cms_pages(:child)
    page.slug = 'slug.with.d0ts-and_things'
    assert page.valid?
    
    page.slug = 'inva lid'
    assert page.invalid?

    page.slug = 'acción'
    assert page.valid?
  end

  def test_validation_of_slug_allows_unicode_accent_characters
    page = cms_pages(:child)
    thai_character_ko_kai = "\u0e01"
    thai_character_mai_tho = "\u0E49"
    page.slug = thai_character_ko_kai + thai_character_mai_tho
    assert page.valid?
  end

  def test_label_assignment
    page = cms_sites(:default).pages.new(
      :slug   => 'test',
      :parent => cms_pages(:default),
      :layout => cms_layouts(:default)
    )
    assert page.valid?
    assert_equal 'Test', page.label
  end
  
  def test_creation
    assert_difference ['Cms::Page.count', 'Cms::Block.count'] do
      page = cms_sites(:default).pages.create!(
        :label  => 'test',
        :slug   => 'test',
        :parent => cms_pages(:default),
        :layout => cms_layouts(:default),
        :blocks_attributes => [
          { :identifier => 'default_page_text',
            :content    => 'test' }
        ]
      )
      assert page.is_published?
      assert_equal 1, page.position
    end
  end
  
  def test_initialization_of_full_path
    page = Cms::Page.new
    assert_equal '/', page.full_path
    
    page = Cms::Page.new(new_params)
    assert page.invalid?
    assert_has_errors_on page, :site_id
    
    page = cms_sites(:default).pages.new(new_params(:parent => cms_pages(:default)))
    assert page.valid?
    assert_equal '/test-page', page.full_path
    
    page = cms_sites(:default).pages.new(new_params(:parent => cms_pages(:child)))
    assert page.valid?
    assert_equal '/child-page/test-page', page.full_path
    
    Cms::Page.destroy_all
    page = cms_sites(:default).pages.new(new_params)
    assert page.valid?
    assert_equal '/', page.full_path
  end
  
  def test_sync_child_pages
    page = cms_pages(:child)
    page_1 = cms_sites(:default).pages.create!(new_params(:parent => page, :slug => 'test-page-1'))
    page_2 = cms_sites(:default).pages.create!(new_params(:parent => page, :slug => 'test-page-2'))
    page_3 = cms_sites(:default).pages.create!(new_params(:parent => page_2, :slug => 'test-page-3'))
    page_4 = cms_sites(:default).pages.create!(new_params(:parent => page_1, :slug => 'test-page-4'))
    assert_equal '/child-page/test-page-1', page_1.full_path
    assert_equal '/child-page/test-page-2', page_2.full_path
    assert_equal '/child-page/test-page-2/test-page-3', page_3.full_path
    assert_equal '/child-page/test-page-1/test-page-4', page_4.full_path
    
    page.update_attributes!(:slug => 'updated-page')
    assert_equal '/updated-page', page.full_path
    page_1.reload; page_2.reload; page_3.reload; page_4.reload
    assert_equal '/updated-page/test-page-1', page_1.full_path
    assert_equal '/updated-page/test-page-2', page_2.full_path
    assert_equal '/updated-page/test-page-2/test-page-3', page_3.full_path
    assert_equal '/updated-page/test-page-1/test-page-4', page_4.full_path
    
    page_2.update_attributes!(:parent => page_1)
    page_1.reload; page_2.reload; page_3.reload; page_4.reload
    assert_equal '/updated-page/test-page-1', page_1.full_path
    assert_equal '/updated-page/test-page-1/test-page-2', page_2.full_path
    assert_equal '/updated-page/test-page-1/test-page-2/test-page-3', page_3.full_path
    assert_equal '/updated-page/test-page-1/test-page-4', page_4.full_path
  end
  
  def test_children_count_updating
    page_1 = cms_pages(:default)
    page_2 = cms_pages(:child)
    assert_equal 1, page_1.children_count
    assert_equal 0, page_2.children_count
    
    page_3 = cms_sites(:default).pages.create!(new_params(:parent => page_2))
    page_1.reload; page_2.reload
    assert_equal 1, page_1.children_count
    assert_equal 1, page_2.children_count
    assert_equal 0, page_3.children_count
    
    page_3.update_attributes!(:parent => page_1)
    page_1.reload; page_2.reload
    assert_equal 2, page_1.children_count
    assert_equal 0, page_2.children_count
    
    page_3.destroy
    page_1.reload; page_2.reload
    assert_equal 1, page_1.children_count
    assert_equal 0, page_2.children_count
  end
  
  def test_cascading_destroy
    assert_difference 'Cms::Page.count', -2 do
      assert_difference 'Cms::Block.count', -2 do
        cms_pages(:default).destroy
      end
    end
  end
  
  def test_options_for_select
    assert_equal ['Default Page', '. . Child Page'], 
      Cms::Page.options_for_select(cms_sites(:default)).collect{|t| t.first }
    assert_equal ['Default Page'], 
      Cms::Page.options_for_select(cms_sites(:default), cms_pages(:child)).collect{|t| t.first }
    assert_equal [], 
      Cms::Page.options_for_select(cms_sites(:default), cms_pages(:default))
    
    page = Cms::Page.new(new_params(:parent => cms_pages(:default)))
    assert_equal ['Default Page', '. . Child Page'],
      Cms::Page.options_for_select(cms_sites(:default), page).collect{|t| t.first }
  end
  
  def test_cms_blocks_attributes_accessor
    page = cms_pages(:default)
    assert_equal page.blocks.count, page.blocks_attributes.size
    assert_equal 'default_field_text', page.blocks_attributes.first[:identifier]
    assert_equal 'default_field_text_content', page.blocks_attributes.first[:content]
  end
  
  def test_content_caching
    page = cms_pages(:default)
    assert_equal page.content, page.render
    
    page.update_columns(:content => 'Old Content')
    refute_equal page.content, page.render
    
    page.clear_cached_content!
    assert_equal page.content, page.render
  end
  
  def test_scope_published
    assert_equal 2, Cms::Page.published.count
    cms_pages(:child).update_columns(:is_published => false)
    assert_equal 1, Cms::Page.published.count
  end
  
  def test_root?
    assert cms_pages(:default).root?
    assert !cms_pages(:child).root?
  end
  
  def test_url
    site = cms_sites(:default)
    
    assert_equal '//test.host/', cms_pages(:default).url
    assert_equal '//test.host/child-page', cms_pages(:child).url
    
    site.update_columns(:path => '/en/site')
    cms_pages(:default).reload
    cms_pages(:child).reload
    
    assert_equal '//test.host/en/site/', cms_pages(:default).url
    assert_equal '//test.host/en/site/child-page', cms_pages(:child).url
  end

  def test_unicode_slug_escaping
    page = cms_pages(:child)
    page_1 = cms_sites(:default).pages.create!(new_params(:parent => page, :slug => 'tést-ünicode-slug'))
    assert_equal CGI::escape('tést-ünicode-slug'), page_1.slug
    assert_equal CGI::escape('/child-page/tést-ünicode-slug').gsub('%2F', '/'), page_1.full_path
  end

  def test_unicode_slug_unescaping
    page = cms_pages(:child)
    page_1 = cms_sites(:default).pages.create!(new_params(:parent => page, :slug => 'tést-ünicode-slug'))
    found_page = cms_sites(:default).pages.where(:slug => CGI::escape('tést-ünicode-slug')).first
    assert_equal 'tést-ünicode-slug', found_page.slug
    assert_equal '/child-page/tést-ünicode-slug', found_page.full_path
  end
  
  def test_identifier
    assert_equal 'index',       cms_pages(:default).identifier
    assert_equal 'child-page',  cms_pages(:child).identifier
    
    cms_pages(:default).update_column(:slug, 'index')
    assert_equal 'index', cms_pages(:default).identifier
  end
  
protected
  
  def new_params(options = {})
    {
      :label  => 'Test Page',
      :slug   => 'test-page',
      :layout => cms_layouts(:default)
    }.merge(options)
  end
end
