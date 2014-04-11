require_relative '../test_helper'

class MirrorsIntegrationTest < ActionDispatch::IntegrationTest
  
  def setup
    @site_a = comfy_cms_sites(:default)
    @site_a.update_columns(:is_mirrored => true)
    @site_b = Comfy::Cms::Site.create!(:identifier => 'test_b', :hostname => 'test-b.host', :is_mirrored => true)
    # making mirrors
    Comfy::Cms::Layout.all.each{ |l| l.save! }
    Comfy::Cms::Page.all.each{ |p| p.save! }
    Comfy::Cms::Snippet.all.each { |s| s.save! }
  end
  
  def test_get_layouts
    http_auth :get, comfy_admin_cms_site_layouts_path(@site_a)
    assert_response :success
    assert_select 'select#mirror' do
      assert_select "option[value='/admin/sites/#{@site_b.id}/layouts']"
    end
  end
  
  def test_get_layouts_edit
    layout = comfy_cms_layouts(:default)
    assert mirror = layout.mirrors.first
    
    http_auth :get, edit_comfy_admin_cms_site_layout_path(@site_a, layout)
    assert_response :success
    assert_select 'select#mirror' do
      assert_select "option[value='/admin/sites/#{@site_b.id}/layouts/#{mirror.id}/edit']"
    end
  end
  
  def test_get_pages
    http_auth :get, comfy_admin_cms_site_pages_path(@site_a)
    assert_response :success
    assert_select 'select#mirror' do
      assert_select "option[value='/admin/sites/#{@site_b.id}/pages']"
    end
  end
  
  def test_get_pages_edit
    page = comfy_cms_pages(:default)
    assert mirror = page.mirrors.first
    
    http_auth :get, edit_comfy_admin_cms_site_page_path(@site_a, page)
    assert_response :success
    assert_select 'select#mirror' do
      assert_select "option[value='/admin/sites/#{@site_b.id}/pages/#{mirror.id}/edit']"
    end
  end
  
  def test_get_snippets
    http_auth :get, comfy_admin_cms_site_snippets_path(@site_a)
    assert_response :success
    assert_select 'select#mirror' do
      assert_select "option[value='/admin/sites/#{@site_b.id}/snippets']"
    end
  end
  
  def test_get_snippets_edit
    snippet = comfy_cms_snippets(:default)
    assert mirror = snippet.mirrors.first
    
    http_auth :get, edit_comfy_admin_cms_site_snippet_path(@site_a, snippet)
    assert_response :success
    assert_select 'select#mirror' do
      assert_select "option[value='/admin/sites/#{@site_b.id}/snippets/#{mirror.id}/edit']"
    end
  end
  
end