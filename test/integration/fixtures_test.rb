require File.expand_path('../test_helper', File.dirname(__FILE__))

class FixturesTest < ActionDispatch::IntegrationTest
  
  def test_inactivity
    assert_equal false, ComfortableMexicanSofa.config.enable_fixtures
    assert_no_difference ['Cms::Layout.count', 'Cms::Page.count', 'Cms::Block.count', 'Cms::Snippet.count'] do
      get '/'
      assert_response :success
    end
  end
  
  def test_initialization
    ComfortableMexicanSofa.config.enable_fixtures = true
    get '/'
  end
  
  def test_layout_file_update
    flunk
  end
  
  def test_page_file_update
    flunk
  end
  
  def test_snippet_file_update
    flunk
  end
  
  def test_layout_file_removal
    flunk
  end
  
  def test_page_file_removal
    flunk
  end
  
  def test_snippet_file_removal
    flunk
  end
  
  def test_layout_creation_failure
    flunk
  end
  
  def test_page_creation_failure
    flunk
  end
  
  def test_snippet_creation_failure
    flunk
  end
  
  def test_single_site_path_option
    flunk
  end
  
end