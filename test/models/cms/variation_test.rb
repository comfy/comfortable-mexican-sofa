require_relative '../../test_helper'

class CmsVariationTest < ActiveSupport::TestCase
  
  def test_fixtures_validity
    Cms::Variation.all.each do |variation|
      assert variation.valid?, variation.errors.full_messages.to_s
    end
  end
  
  def test_validations
    variation = Cms::Variation.new
    assert variation.invalid?
    assert_has_errors_on variation, :content, :identifier
  end

  def test_validation_uniqueness
    variation = Cms::Variation.new(
      :content    => cms_variations(:default).content,
      :identifier => cms_variations(:default).identifier
    )
    assert variation.invalid?
    assert_has_errors_on variation, :identifier
  end

  def test_creation
    assert_difference 'Cms::Variation.count' do
      Cms::Variation.create(
        :content    => cms_page_contents(:default),
        :identifier => 'test'
      )
    end
  end

  def test_list
    ComfortableMexicanSofa.config.variations = {:en => [:region_a, :region_b], :fr => [:region_a, :region_b]}
    assert_equal ['en.region_a', 'en.region_b', 'fr.region_a', 'fr.region_b'], Cms::Variation.list
    ComfortableMexicanSofa.config.variations = [:en, :fr, :es]
    assert_equal ['en', 'fr', 'es'], Cms::Variation.list
  end

end
