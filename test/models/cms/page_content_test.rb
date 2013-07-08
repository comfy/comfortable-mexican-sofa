# encoding: utf-8
require_relative '../../test_helper'

class CmsPageContentTest < ActiveSupport::TestCase

  def test_fixtures_validity
    Cms::PageContent.all.each do |pc|
      assert pc.valid?, pc.errors.full_messages.to_s
      # assert_equal pc.read_attribute(:content), pc.content(true)
    end
  end
  
  def test_validations
    flunk
  end

  def test_creation
    flunk
  end

  def test_creation_with_variations
    flunk
  end

  def test_validations_with_variations
    flunk
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
