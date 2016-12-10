require_relative '../test_helper'

class CmsSiteTest < ActiveSupport::TestCase
  
  def test_fixtures_validity
    Comfy::Cms::Site.all.each do |site|
      assert site.valid?, site.errors.inspect
    end
  end
  
  def test_validation
    site = Comfy::Cms::Site.new
    assert site.invalid?
    assert_has_errors_on site, [:identifier, :label, :hostname]
    
    site = Comfy::Cms::Site.new(:identifier => 'test', :hostname => 'http://site.host')
    assert site.invalid?
    assert_has_errors_on site, :hostname
    
    site = Comfy::Cms::Site.new(:identifier => comfy_cms_sites(:default).identifier, :hostname => 'site.host')
    assert site.invalid?
    assert_has_errors_on site, :identifier
    
    site = Comfy::Cms::Site.new(:identifier => 'test', :hostname => 'site.host')
    assert site.valid?, site.errors.inspect
    
    site = Comfy::Cms::Site.new(:identifier => 'test', :hostname => 'localhost:3000')
    assert site.valid?, site.errors.inspect
  end
  
  def test_validation_path_uniqueness
    s1 = comfy_cms_sites(:default)
    s2 = Comfy::Cms::Site.new(
      :identifier => 'test',
      :hostname   => s1.hostname,
      :path       => s1.path
    )
    assert s2.invalid?
    assert_has_errors_on s2, :hostname
    
    s2 = Comfy::Cms::Site.new(
      :identifier => 'test',
      :hostname   => s1.hostname,
      :path       => '/en'
    )
    assert s2.valid?
  end
  
  def test_identifier_assignment
    site = Comfy::Cms::Site.new(:hostname => 'my-site.host')
    assert site.valid?
    assert_equal 'my-site-host', site.identifier
  end
  
  def test_hostname_assignment
    site = Comfy::Cms::Site.new(:identifier => 'test-site')
    assert site.valid?
    assert_equal 'test-site', site.hostname
  end
  
  def test_label_assignment
    site = Comfy::Cms::Site.new(:identifier => 'test', :hostname => 'my-site.host')
    assert site.valid?
    assert_equal 'Test', site.label
  end
  
  def test_clean_path
    site = Comfy::Cms::Site.create!(:identifier => 'test_a', :hostname => 'test.host', :path => '/en///test//')
    assert_equal '/en/test', site.path
    
    site = Comfy::Cms::Site.create!(:identifier => 'test_b', :hostname => 'my-site.host', :path => '/')
    assert_equal '', site.path
  end
  
  def test_creation
    assert_difference 'Comfy::Cms::Site.count' do
      Comfy::Cms::Site.create!(
        :identifier => 'test',
        :label      => 'Test Site',
        :hostname   => 'test.test'
      )
    end
  end
  
  def test_cascading_destroy
    assert_difference 'Comfy::Cms::Site.count', -1 do
      assert_difference 'Comfy::Cms::Layout.count', -3 do
        assert_difference 'Comfy::Cms::Page.count', -2 do
          assert_difference 'Comfy::Cms::Snippet.count', -1 do
            assert_difference 'Comfy::Cms::Category.count', -1 do
              comfy_cms_sites(:default).destroy
            end
          end
        end
      end
    end
  end
  
  def test_scope_mirrored
    site = comfy_cms_sites(:default)
    assert !site.is_mirrored
    assert_equal 0, Comfy::Cms::Site.mirrored.count
    site.update_columns(:is_mirrored => true)
    assert_equal 1, Comfy::Cms::Site.mirrored.count
  end
  
  def test_find_site
    site_a = comfy_cms_sites(:default)
    assert_equal 'test.host', site_a.hostname
    assert_nil site_a.path
    
    assert_equal site_a, Comfy::Cms::Site.find_site('test.host')
    assert_equal site_a, Comfy::Cms::Site.find_site('test.host', '/some/path')
    assert_equal site_a, Comfy::Cms::Site.find_site('test99.host', '/some/path')
    
    site_b = Comfy::Cms::Site.create!(:identifier => 'test_a', :hostname => 'test2.host', :path => 'en')
    site_c = Comfy::Cms::Site.create!(:identifier => 'test_b', :hostname => 'test2.host', :path => 'fr')
    
    assert_equal site_a,  Comfy::Cms::Site.find_site('test.host')
    assert_equal site_a,  Comfy::Cms::Site.find_site('test.host', '/some/path')
    assert_equal site_a,  Comfy::Cms::Site.find_site('test.host', '/some/path')
    assert_nil            Comfy::Cms::Site.find_site('test99.host', '/some/path')
    
    assert_nil            Comfy::Cms::Site.find_site('test2.host')
    assert_nil            Comfy::Cms::Site.find_site('test2.host', '/some/path')
    assert_equal site_b,  Comfy::Cms::Site.find_site('test2.host', '/en')
    assert_equal site_b,  Comfy::Cms::Site.find_site('test2.host', '/en?a=b')
    assert_equal site_b,  Comfy::Cms::Site.find_site('test2.host', '/en/some/path?a=b')
    
    assert_nil            Comfy::Cms::Site.find_site('test2.host', '/english/some/path')
    
    assert_equal site_c,  Comfy::Cms::Site.find_site('test2.host', '/fr')
    assert_equal site_c,  Comfy::Cms::Site.find_site('test2.host', '/fr?a=b')
    assert_equal site_c,  Comfy::Cms::Site.find_site('test2.host', '/fr/some/path')
    assert_equal site_c,  Comfy::Cms::Site.find_site('test2.host', '/fr/some/path?a=b')
  end
  
  def test_find_site_with_site_alias
    site_a = comfy_cms_sites(:default)
    site_b = Comfy::Cms::Site.create!(:identifier => 'site_b', :hostname => 'test2.host')
    
    ComfortableMexicanSofa.config.hostname_aliases = {
      'test.host'   => 'alias_a.host',
      'test2.host'  => %w(alias_b.host alias_c.host)
    }
    
    assert_equal site_a, Comfy::Cms::Site.find_site('alias_a.host')
    assert_equal site_b, Comfy::Cms::Site.find_site('alias_b.host')
    assert_equal site_b, Comfy::Cms::Site.find_site('alias_c.host')
  end
  
  def test_url
    assert_equal '//test.host/', comfy_cms_sites(:default).url
  end
  
  def test_url_with_public_cms_path
    ComfortableMexicanSofa.config.public_cms_path = '/custom'
    assert_equal '//test.host/custom/', comfy_cms_sites(:default).url
  end
  
end