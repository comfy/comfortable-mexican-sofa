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
        :variation_identifiers => ['en']
      )
    end
  end

  def test_creation_with_variations
    page = cms_pages(:default)
    assert_difference ["Cms::Variation.count"], 3 do
      page.page_contents.create!(
        :variation_identifiers => ['cn', 'fr', 'jp']
      )
    end
    assert_equal 'jp', page.page_contents.last.variations.last.identifier
  end

  def test_validations
    flunk
  end

  def test_variation_identifiers
    page = cms_pages(:default)
    assert_equal ['en'], page.page_content.variation_identifiers
  end

  def test_set_variation_identifiers
    pc = cms_page_contents(:default)
    pc.variation_identifiers = ['en', 'fr', 'jp']
    pc.save
    assert_equal ['en', 'fr', 'jp'], pc.variation_identifiers
  end

  def test_validates_unique_variation
    page = cms_pages(:default)
    pc = page.page_contents.build(:variation_identifiers => ['en'])
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

end
