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
    
    site = Cms::Site.new(:label => 'My Site', :hostname => 'http://mysite.com')
    assert site.invalid?
    assert_has_errors_on site, :hostname
    
    site = Cms::Site.new(:label => 'My Site', :hostname => 'mysite.com')
    assert site.valid?
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
  
  def test_options_for_select
    assert_equal 1, Cms::Site.options_for_select.size
    assert_equal 'Default Site (test.host)', Cms::Site.options_for_select[0][0]
  end
  
end