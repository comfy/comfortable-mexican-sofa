# encoding: utf-8
require_relative '../../test_helper'

class CmsPageContentTest < ActiveSupport::TestCase

  def test_fixtures_validity
    Cms::PageContent.all.each do |pc|
      assert pc.valid?, pc.errors.full_messages.to_s
    end
  end

  def test_creation
    page = cms_pages(:default)
    assert_difference "Cms::PageContent.count" do
      pc = page.page_contents.create!(
        :slug                  => 'creation',
        :variation_identifiers => {'pp' => 1}
      )
    end
  end

  def test_creation_with_variations
    page = cms_pages(:default)
    assert_difference ["Cms::Variation.count"], 2 do
      page.page_contents.create!(
        :slug                  => 'create-with-variations',
        :variation_identifiers => {'cn' => 1, 'jp' => 1}
      )
    end
    assert_equal 'jp', page.page_contents.last.variations.last.identifier
  end

  def test_sync_variations
    pc = cms_page_contents(:default)
    assert_equal ['fr', 'en'], pc.variation_identifiers
    puts pc.slug
    # assert_no_difference "Cms::Variation.count" do
      pc.update_attributes!(
        :variation_identifiers => {'fr' => 1, 'ru' => 1, 'en' => 0}
      )
    # end
    pc.reload
    assert_equal ['fr', 'ru'], pc.variation_identifiers

    assert_difference "Cms::Variation.count", -2 do
      pc.update_attributes!(
        :variation_identifiers => {'fr' => 0, 'ru' => 0}
      )
    end
    pc.reload
    assert_equal [], pc.variation_identifiers
  end

  def test_validations
    page_content = Cms::PageContent.new(
      :page => cms_pages(:child)
    )
    assert page_content.invalid?
    assert_has_errors_on page_content, [:slug]
  end

  def test_validate_at_least_one_variation
    ComfortableMexicanSofa.config.variations = [:en, :fr]
    page_content = Cms::PageContent.new(
      :page => cms_pages(:child)
    )
    assert page_content.invalid?
    assert_has_errors_on page_content, [:slug, :base]
  end

  def test_variation_identifiers
    page = cms_pages(:default)
    assert_equal ['fr', 'en'], page.page_content.variation_identifiers
  end

  def test_set_variation_identifiers
    pc = cms_page_contents(:default)
    pc.variation_identifiers = {'en' => 1, 'fr' => 1, 'jp' => 1}
    pc.save
    assert_equal ['fr', 'en', 'jp'], pc.variation_identifiers
  end

  def test_validates_unique_variation
    # TODO: fix this test
    page = cms_pages(:default)
    pc   = page.page_contents.create(
      :slug                  => 'unique-variation',
      :variation_identifiers => {'en' => 1}
    )
    assert pc.invalid?
    assert pc.errors.messages['variations.identifier'.to_sym]
  end

  def test_delegations
    assert_equal cms_sites(:default), cms_page_contents(:default).site
  end

  def test_scope_for_variation_without_variations
    assert ComfortableMexicanSofa.config.variations.nil?
    assert_equal 2, Cms::PageContent.for_variation('en').count
    assert_equal 2, Cms::PageContent.for_variation('invalid').count

    ComfortableMexicanSofa.config.variations = ['en', 'fr']
    assert_equal 1, Cms::PageContent.for_variation('en').count
    assert_equal 0, Cms::PageContent.for_variation('invalid').count
  end

  def test_cms_blocks_attributes_accessor
    pc = cms_page_contents(:default)
    assert_equal pc.blocks.count, pc.blocks_attributes.size
    assert_equal 'default_field_text', pc.blocks_attributes.first[:identifier]
    assert_equal 'default_field_text_content', pc.blocks_attributes.first[:content]
  end

  def test_validation_of_slug
    pc = cms_page_contents(:default)
    pc.slug = 'slug.with.d0ts-and_things'
    assert pc.valid?
    
    pc.slug = 'inva lid'
    assert pc.invalid?

    pc.slug = 'acción'
    assert pc.valid?
  end

  def test_validation_of_slug_allows_unicode_accent_characters
    pc = cms_page_contents(:default)
    thai_character_ko_kai = "\u0e01"
    thai_character_mai_tho = "\u0E49"
    pc.slug = thai_character_ko_kai + thai_character_mai_tho
    assert pc.valid?
  end

  def test_unicode_slug_escaping
    page = cms_pages(:child)
    page_1 = cms_sites(:default).pages.create!(
      :parent => page,
      :label  => 'Test',
      :layout => cms_layouts(:default),
      :page_content_attributes => {
        :slug => 'tést-ünicode-slug',
        :variation_identifiers => {'en' => 1}
      }
    )
    assert_equal CGI::escape('tést-ünicode-slug'), page_1.page_content.slug
    assert_equal CGI::escape('/child/tést-ünicode-slug').gsub('%2F', '/'), page_1.page_content.full_path
  end

  def test_unicode_slug_unescaping
    page = cms_pages(:child)
    page_1 = cms_sites(:default).pages.create!(
      :parent => page,
      :label  => 'Internation',
      :layout => cms_layouts(:default),
      :page_content_attributes => {
         :slug => 'tést-ünicode-slug',
         :variation_identifiers => {'en' => 1}
      }
    )
    found_page_content = Cms::PageContent.where(:slug => CGI::escape('tést-ünicode-slug')).first 

    # cms_sites(:default).pages.where(:slug => CGI::escape('tést-ünicode-slug')).first
    assert_equal 'tést-ünicode-slug', found_page_content.slug
    assert_equal '/child/tést-ünicode-slug', found_page_content.full_path
  end

  def test_url
    site = cms_sites(:default)
    
    assert_equal 'http://test.host/', cms_page_contents(:default).url
    assert_equal 'http://test.host/child', cms_page_contents(:child).url
    
    site.update_columns(:path => '/en/site')
    cms_page_contents(:default).reload
    cms_page_contents(:child).reload
    
    assert_equal 'http://test.host/en/site/', cms_page_contents(:default).url
    assert_equal 'http://test.host/en/site/child', cms_page_contents(:child).url
  end

  #-- Full Path Tests -----------------------------------------------------
  def test_root_full_path
    site = cms_sites(:default)
    site.pages.destroy_all
    root_path = site.pages.create!(
      :label     => 'Homepage',
      :layout_id => cms_layouts(:default).id,
      :page_content_attributes => {
        :slug => 'does-not-apply-to-root',
        :variation_identifiers => {'en' => 1}
      }
    )
    pc = Cms::PageContent.last
    assert_equal "does-not-apply-to-root", pc.slug
    assert_equal "/", pc.full_path
  end

  def test_full_path_with_matching_identifiers
    site  = cms_sites(:default)
    page  = cms_pages(:default)
    child = site.pages.create!(
      :parent_id => page.id,
      :label     => 'Child Page',
      :layout_id => cms_layouts(:default).id,
      :page_content_attributes => {
        :slug => 'first-level-page',
        :variation_identifiers => {'en' => 1}
      }
    )
    assert_equal 'first-level-page',  child.page_content.slug
    assert_equal '/first-level-page', child.page_content.full_path
  end

  def test_full_path_with_deeply_nested_matching_identifiers
    site  = cms_sites(:default)
    page  = cms_pages(:default)
    # Create the first child
    first_child = site.pages.create!(
      :parent_id => page.id,
      :label     => 'First Child',
      :layout_id => cms_layouts(:default).id,
      :page_content_attributes => {
        :slug => 'le-first-child',
        :variation_identifiers => {'fr' => 1}
      }
    )
    assert_equal '/le-first-child', first_child.page_content.full_path

    # Create the second child
    second_child = site.pages.create!(
      :parent_id => first_child.id,
      :label     => 'Second Child',
      :layout_id => cms_layouts(:default).id,
      :page_content_attributes => {
        :slug => 'le-second-child',
        :variation_identifiers => {'fr' => 1}
      }
    )
    assert_equal '/le-first-child/le-second-child', second_child.page_content.full_path
  end

  def test_full_path_with_mixed_identifier
    site  = cms_sites(:default)
    page  = cms_pages(:default)
    # Create the first child
    first_child = site.pages.create!(
      :parent_id => page.id,
      :label     => 'First Child',
      :layout_id => cms_layouts(:default).id,
      :page_content_attributes => {
        :slug => 'en-first-child',
        :variation_identifiers => {'en' => 1}
      }
    )
    assert_equal '/en-first-child', first_child.page_content.full_path

    # Create the second child
    second_child = site.pages.create!(
      :parent_id => first_child.id,
      :label     => 'Second Child',
      :layout_id => cms_layouts(:default).id,
      :page_content_attributes => {
        :slug => 'le-second-child',
        :variation_identifiers => {'fr' => 1}
      }
    )
    assert_equal '/en-first-child/le-second-child', second_child.page_content.full_path
  end

  def test_content_caching
    skip
    # pc = cms_page_contents(:default)
    # assert_equal pc.read_attribute(:content), pc.content
    # assert_equal pc.read_attribute(:content), pc.content(true)
    
    # pc.update_attributes(:content => 'changed')
    # pc.reload
    # assert_equal pc.read_attribute(:content), pc.content
    # assert_equal pc.read_attribute(:content), pc.content(true)

    # assert_not_equal 'changed', page.read_attribute(:content)
  end


  def test_path_validations
    # 1. when removing pc variation identifier, need to make sure that none of its children have this variation identifier
    # 2. when adding pc variation identifier, need to make sure that all ancestors have with variation identifier present
  end


end
