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
    assert_difference ["Cms::Variation.count"], 3 do
      page.page_contents.create!(
        :slug                  => 'create-with-variations',
        :variation_identifiers => {'cn' => 1, 'fr' => 1, 'jp' => 1}
      )
    end
    assert_equal 'jp', page.page_contents.last.variations.last.identifier
  end

  def test_sync_variations
    pc = cms_page_contents(:default)
    assert_equal ['fr', 'en'], pc.variation_identifiers 
    assert_no_difference "Cms::Variation.count" do
      pc.update_attributes!(
        :variation_identifiers => {'fr' => 1, 'ru' => 1, 'en' => 0}
      )
    end
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
    flunk
  end

  def test_validate_at_least_one_variation
    flunk
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
    pc   = page.page_contents.build(
      :slug                  => 'unique-variation',
      :variation_identifiers => {'en' => 1}
    )
    assert !pc.valid?
    assert_has_errors_on pc, :variation_identifiers
  end

  def test_delegations
    assert_equal cms_sites(:default), cms_page_contents(:default).site
  end

  def test_scope_for_variation_without_variations
    assert ComfortableMexicanSofa.config.variations.nil?
    assert_equal 1, Cms::PageContent.for_variation('en').count
    assert_equal 1, Cms::PageContent.for_variation('invalid').count

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

  def test_assign_full_path
    parent = cms_pages(:default)
    child  = cms_pages(:child)
    pc = child.page_contents.create!(
      :slug                  => 'en-child',
      :variation_identifiers => {'en' => 1}
    )
    assert_equal '/default/en-child', pc.full_path

    pc = child.page_contents.create!(
      :slug => 'fr-child',
      :variation_identifiers => {'fr' => 1}
    )
    assert_equal '/default/fr-child', pc.full_path

    pc = child.page_contents.create!(
      :slug => 'mixed-child',
      :variation_identifiers => {'en' => 1, 'fr' => 1}
    )
    assert_equal '/default/mixed-child', pc.full_path

  end

  def test_path_validations
    # 1. when removing pc variation identifier, need to make sure that none of its children have this variation identifier
    # 2. when adding pc variation identifier, need to make sure that all ancestors have with variation identifier present
  end


end
