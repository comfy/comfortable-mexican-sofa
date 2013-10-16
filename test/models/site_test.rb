require_relative '../test_helper'

class CmsSiteTest < ActiveSupport::TestCase
  
  def test_fixtures_validity
    Cms::Site.all.each do |site|
      assert site.valid?, site.errors.inspect
    end
  end
  
  def test_validation
    site = Cms::Site.new
    assert site.invalid?
    assert_has_errors_on site, [:identifier, :label, :hostname]
    
    site = Cms::Site.new(:identifier => 'test', :hostname => 'http://site.host')
    assert site.invalid?
    assert_has_errors_on site, :hostname
    
    site = Cms::Site.new(:identifier => cms_sites(:default).identifier, :hostname => 'site.host')
    assert site.invalid?
    assert_has_errors_on site, :identifier
    
    site = Cms::Site.new(:identifier => 'test', :hostname => 'site.host')
    assert site.valid?, site.errors.inspect
    
    site = Cms::Site.new(:identifier => 'test', :hostname => 'localhost:3000')
    assert site.valid?, site.errors.inspect
  end
  
  def test_validation_path_uniqueness
    s1 = cms_sites(:default)
    s2 = Cms::Site.new(
      :identifier => 'test',
      :hostname   => s1.hostname,
      :path       => s1.path
    )
    assert s2.invalid?
    assert_has_errors_on s2, :hostname
    
    s2 = Cms::Site.new(
      :identifier => 'test',
      :hostname   => s1.hostname,
      :path       => '/en'
    )
    assert s2.valid?
  end
  
  def test_identifier_assignment
    site = Cms::Site.new(:hostname => 'my-site.host')
    assert site.valid?
    assert_equal 'my-site-host', site.identifier
  end
  
  def test_hostname_assignment
    site = Cms::Site.new(:identifier => 'test-site')
    assert site.valid?
    assert_equal 'test-site', site.hostname
  end
  
  def test_label_assignment
    site = Cms::Site.new(:identifier => 'test', :hostname => 'my-site.host')
    assert site.valid?
    assert_equal 'Test', site.label
  end
  
  def test_clean_path
    site = Cms::Site.create!(:identifier => 'test_a', :hostname => 'test.host', :path => '/en///test//')
    assert_equal '/en/test', site.path
    
    site = Cms::Site.create!(:identifier => 'test_b', :hostname => 'my-site.host', :path => '/')
    assert_equal '', site.path
  end
  
  def test_creation
    assert_difference 'Cms::Site.count' do
      Cms::Site.create!(
        :identifier => 'test',
        :label      => 'Test Site',
        :hostname   => 'test.test'
      )
    end
  end
  
  def test_cascading_destroy
    assert_difference 'Cms::Site.count', -1 do
      assert_difference 'Cms::Layout.count', -3 do
        assert_difference 'Cms::Page.count', -2 do
          assert_difference 'Cms::Snippet.count', -1 do
            assert_difference 'Cms::Category.count', -1 do
              cms_sites(:default).destroy
            end
          end
        end
      end
    end
  end
  
  def test_scope_mirrored
    site = cms_sites(:default)
    assert !site.is_mirrored
    assert_equal 0, Cms::Site.mirrored.count
    site.update_columns(:is_mirrored => true)
    assert_equal 1, Cms::Site.mirrored.count
  end
  
  def test_find_site
    site_a = cms_sites(:default)
    assert_equal 'test.host', site_a.hostname
    assert_equal nil, site_a.path
    
    assert_equal site_a, Cms::Site.find_site('test.host')
    assert_equal site_a, Cms::Site.find_site('test.host', '/some/path')
    assert_equal site_a, Cms::Site.find_site('test99.host', '/some/path')
    
    site_b = Cms::Site.create!(:identifier => 'test_a', :hostname => 'test2.host', :path => 'en')
    site_c = Cms::Site.create!(:identifier => 'test_b', :hostname => 'test2.host', :path => 'fr')
    
    assert_equal site_a,  Cms::Site.find_site('test.host')
    assert_equal site_a,  Cms::Site.find_site('test.host', '/some/path')
    assert_equal site_a,  Cms::Site.find_site('test.host', '/some/path')
    assert_equal nil,     Cms::Site.find_site('test99.host', '/some/path')
    
    assert_equal nil,     Cms::Site.find_site('test2.host')
    assert_equal nil,     Cms::Site.find_site('test2.host', '/some/path')
    assert_equal site_b,  Cms::Site.find_site('test2.host', '/en')
    assert_equal site_b,  Cms::Site.find_site('test2.host', '/en?a=b')
    assert_equal site_b,  Cms::Site.find_site('test2.host', '/en/some/path?a=b')
    
    assert_equal nil,     Cms::Site.find_site('test2.host', '/english/some/path')
    
    assert_equal site_c,  Cms::Site.find_site('test2.host', '/fr')
    assert_equal site_c,  Cms::Site.find_site('test2.host', '/fr?a=b')
    assert_equal site_c,  Cms::Site.find_site('test2.host', '/fr/some/path')
    assert_equal site_c,  Cms::Site.find_site('test2.host', '/fr/some/path?a=b')
  end
  
  def test_find_site_with_site_alias
    site_a = cms_sites(:default)
    site_b = Cms::Site.create!(:identifier => 'site_b', :hostname => 'test2.host')
    
    ComfortableMexicanSofa.config.hostname_aliases = {
      'test.host'   => 'alias_a.host',
      'test2.host'  => %w(alias_b.host alias_c.host)
    }
    
    assert_equal site_a, Cms::Site.find_site('alias_a.host')
    assert_equal site_b, Cms::Site.find_site('alias_b.host')
    assert_equal site_b, Cms::Site.find_site('alias_c.host')
  end
  
end