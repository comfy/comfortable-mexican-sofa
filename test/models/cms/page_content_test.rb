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

end
