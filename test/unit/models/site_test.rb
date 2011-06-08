require File.expand_path('../../test_helper', File.dirname(__FILE__))

class CmsSiteTest < ActiveSupport::TestCase
  
  def test_fixtures_validity
    Cms::Site.all.each do |site|
      assert site.valid?, site.errors.full_messages.to_s
    end
  end
  
  def test_validation
    site = Cms::Site.new
    assert site.invalid?
    assert_has_errors_on site, [:label, :hostname]
    
    site = Cms::Site.new(:label => 'My Site', :hostname => 'http://my-site.host')
    assert site.invalid?
    assert_has_errors_on site, :hostname
    
    site = Cms::Site.new(:label => 'My Site', :hostname => 'my-site.host')
    assert site.valid?
  end
  
  def test_validation_path_uniqueness
    s1 = cms_sites(:default)
    s2 = Cms::Site.new(
      :hostname => s1.hostname,
      :path     => s1.path
    )
    assert s2.invalid?
    assert_has_errors_on s2, :hostname
    
    s2 = Cms::Site.new(
      :hostname => s1.hostname,
      :path     => '/en'
    )
    assert s2.valid?
  end
  
  def test_label_assignment
    site = Cms::Site.new(:hostname => 'my-site.host')
    assert site.valid?
    assert_equal 'my-site.host', site.label
  end
  
  def test_clean_path
    site = Cms::Site.create!(:hostname => 'test.host', :path => '/en///test//')
    assert_equal '/en/test', site.path
    
    site = Cms::Site.create!(:hostname => 'my-site.host', :path => '/')
    assert_equal '', site.path
  end
  
  def test_cascading_destroy
    assert_difference 'Cms::Site.count', -1 do
      assert_difference 'Cms::Layout.count', -3 do
        assert_difference 'Cms::Page.count', -2 do
          assert_difference 'Cms::Snippet.count', -1 do
            cms_sites(:default).destroy
          end
        end
      end
    end
  end
  
  def test_scope_mirrored
    site = cms_sites(:default)
    assert !site.is_mirrored
    assert_equal 0, Cms::Site.mirrored.count
    site.update_attribute(:is_mirrored, true)
    assert_equal 1, Cms::Site.mirrored.count
  end
  
end