require File.expand_path('../test_helper', File.dirname(__FILE__))

class MirrorsTest < ActionDispatch::IntegrationTest
  
  def setup
    ComfortableMexicanSofa.config.enable_mirror_sites = true
    Cms::Site.create!(:hostname => 'test-b.host')
    load(File.expand_path('app/models/cms/layout.rb', Rails.root))
    load(File.expand_path('app/models/cms/page.rb', Rails.root))
    load(File.expand_path('app/models/cms/snippet.rb', Rails.root))
    
    # making mirrors
    Cms::Layout.all.each{ |l| l.save! }
    Cms::Page.all.each{ |p| p.save! }
    Cms::Snippet.all.each { |s| s.save! }
  end
  
  def test_get_layouts
    http_auth :get, cms_admin_layouts_path
    assert_response :success
    assert_select 'select#mirror' do
      assert_select 'option[value="http://test-b.host/cms-admin/layouts"]'
    end
  end
  
  def test_get_layouts_edit
    layout = cms_layouts(:default)
    assert mirror = layout.mirrors.first
    
    http_auth :get, edit_cms_admin_layout_path(layout)
    assert_response :success
    assert_select 'select#mirror' do
      assert_select "option[value='http://test-b.host/cms-admin/layouts/#{mirror.id}/edit']"
    end
  end
  
  def test_get_pages
    http_auth :get, cms_admin_pages_path
    assert_response :success
    assert_select 'select#mirror' do
      assert_select 'option[value="http://test-b.host/cms-admin/pages"]'
    end
  end
  
  def test_get_pages_edit
    page = cms_pages(:default)
    assert mirror = page.mirrors.first
    
    http_auth :get, edit_cms_admin_page_path(page)
    assert_response :success
    assert_select 'select#mirror' do
      assert_select "option[value='http://test-b.host/cms-admin/pages/#{mirror.id}/edit']"
    end
  end
  
  def test_get_snippets
    http_auth :get, cms_admin_snippets_path
    assert_response :success
    assert_select 'select#mirror' do
      assert_select 'option[value="http://test-b.host/cms-admin/snippets"]'
    end
  end
  
  def test_get_snippets_edit
    snippet = cms_snippets(:default)
    assert mirror = snippet.mirrors.first
    
    http_auth :get, edit_cms_admin_snippet_path(snippet)
    assert_response :success
    assert_select 'select#mirror' do
      assert_select "option[value='http://test-b.host/cms-admin/snippets/#{mirror.id}/edit']"
    end
  end
  
end