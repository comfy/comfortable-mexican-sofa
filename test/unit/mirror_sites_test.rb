require File.expand_path('../test_helper', File.dirname(__FILE__))

class MirrorSitesTest < ActiveSupport::TestCase
  
  def setup
    ComfortableMexicanSofa.config.enable_mirror_sites = true
    Cms::Site.destroy_all
    @site_a = Cms::Site.create!(:label => 'Site A', :hostname => 'site-a.host')
    @site_b = Cms::Site.create!(:label => 'Site B', :hostname => 'site-b.host')
  end
  
  def test_layout_creation
    assert_difference 'Cms::Layout.count', 2 do
      @site_a.layouts.create!(:slug => 'default', :content => '{{cms:page:content}}')
      @site_b.reload
      assert_equal 1, @site_b.layouts.count
      layout = @site_b.layouts.first
      assert_equal 'default', layout.slug
    end
  end
  
  def test_page_creation
    
  end
  
  def test_snippet_creation
    
  end
  
  def test_layout_update
    
  end
  
  def test_page_update
    
  end
  
  def test_snippet_update
    
  end
  
  def test_layout_destroy
    
  end
  
  def test_page_destroy
    
  end
  
  def test_snippet_destroy
    
  end
  
end