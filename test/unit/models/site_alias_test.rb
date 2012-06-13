require File.expand_path('../../test_helper', File.dirname(__FILE__))

class CmsSiteAliasTest < ActiveSupport::TestCase

  def test_fixtures_validity
    Cms::SiteAlias.all.each do |site_alias|
      assert site_alias.valid?, site_alias.errors.full_messages.to_s
    end
  end

  def test_validation
    site_alias = cms_sites(:default).site_aliases.new()
    assert site_alias.invalid?
    assert_has_errors_on site_alias, :hostname
  end

  def test_creation
    assert_difference 'Cms::SiteAlias.count' do
      cms_sites(:default).site_aliases.create!(
        :hostname   => 'test.test'
      )
    end
  end
end
