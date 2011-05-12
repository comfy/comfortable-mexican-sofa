require File.expand_path('../test_helper', File.dirname(__FILE__))

class MirrorSitesTest < ActiveSupport::TestCase
  
  def setup
    Cms::Site.destroy_all
    @site_a = Cms::Site.create!(:label => 'Site A', :hostname => 'site-a.host')
    @site_b = Cms::Site.create!(:label => 'Site B', :hostname => 'site-b.host')
  end
  
  def test_layout_creation
    
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