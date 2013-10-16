require_relative '../test_helper'

class MirrorsTest < ActiveSupport::TestCase
  
  def test_layout_creation
    setup_sites
    assert_difference 'Cms::Layout.count', 2 do
      layout = @site_a.layouts.create!(:identifier => 'test')
      assert_equal 1, layout.mirrors.size
      assert_equal 'test', layout.mirrors.first.identifier
    end
  end
  
  def test_page_creation
    setup_sites
    layout = @site_a.layouts.create!(:identifier => 'test')
    
    assert_difference 'Cms::Page.count', 2 do
      page = @site_a.pages.create!(
        :layout => layout,
        :label  => 'Root'
      )
      assert_equal 1, page.mirrors.size
      assert_equal '/', page.mirrors.first.full_path
    end
  end
  
  def test_snippet_creation
    setup_sites
    assert_difference 'Cms::Snippet.count', 2 do
      snippet = @site_a.snippets.create(:identifier => 'test')
      assert_equal 1, snippet.mirrors.size
      assert_equal 'test', snippet.mirrors.first.identifier
    end
  end
  
  def test_layout_update
    setup_sites
    layout_1a = @site_a.layouts.create!(:identifier => 'test_a')
    layout_1b = @site_a.layouts.create!(:identifier => 'test_b')
    layout_1c = @site_a.layouts.create!(:identifier => 'nested', :parent => layout_1a)
    
    assert layout_2a = layout_1a.mirrors.first
    assert layout_2b = layout_1b.mirrors.first
    assert layout_2c = layout_1c.mirrors.first
    assert_equal layout_2a, layout_2c.parent
    
    layout_1c.update_attributes!(
      :identifier => 'updated',
      :parent     => layout_1b,
      :content    => 'updated content'
    )
    layout_2c.reload
    assert_equal 'updated', layout_2c.identifier
    assert_equal layout_2b, layout_2c.parent
    assert_not_equal 'updated content', layout_2c
  end
  
  def test_page_update
    setup_sites
    layout_1a = @site_a.layouts.create!(:identifier => 'test_a')
    layout_1b = @site_a.layouts.create!(:identifier => 'test_b')
    
    page_1r = @site_a.pages.create!(:slug => 'root', :layout => layout_1a)
    page_1a = @site_a.pages.create!(:slug => 'test_a', :layout => layout_1a)
    page_1b = @site_a.pages.create!(:slug => 'test_b', :layout => layout_1a)
    assert_equal page_1r, page_1b.parent
    
    assert layout_2b = layout_1b.mirrors.first
    assert page_2a = page_1a.mirrors.first
    assert page_2b = page_1b.mirrors.first
    
    page_1b.update_attributes!(
      :slug => 'updated',
      :parent => page_1a,
      :layout => layout_1b
    )
    page_2b.reload
    assert_equal 'updated', page_2b.slug
    assert_equal page_2a, page_2b.parent
    assert_equal '/test_a/updated', page_2b.full_path
    assert_equal layout_2b, page_2b.layout
  end
  
  def test_snippet_update
    setup_sites
    snippet_1 = @site_a.snippets.create(:identifier => 'test')
    assert snippet_2 = snippet_1.mirrors.first
    snippet_1.update_attributes!(
      :identifier => 'updated',
      :content    => 'updated content'
    )
    snippet_2.reload
    assert_equal 'updated', snippet_2.identifier
    assert_not_equal 'updated content', snippet_2.content
  end
  
  def test_layout_destroy
    setup_sites
    layout_1a = @site_a.layouts.create!(:identifier => 'test_a')
    layout_1b = @site_a.layouts.create!(:identifier => 'test_b')
    layout_1c = @site_a.layouts.create!(:identifier => 'nested', :parent => layout_1b)
    
    assert layout_2a = layout_1a.mirrors.first
    assert layout_2b = layout_1b.mirrors.first
    assert layout_2c = layout_1c.mirrors.first
    
    assert_difference ['@site_a.layouts.count', '@site_b.layouts.count'], -1 do
      layout_1a.destroy
      assert_nil Cms::Layout.find_by_id(layout_2a.id)
    end
    
    assert_difference ['@site_a.layouts.count', '@site_b.layouts.count'], -2 do
      layout_1b.destroy
      assert_nil Cms::Layout.find_by_id(layout_2b.id)
    end
  end
  
  def test_page_destroy
    setup_sites
    layout = @site_a.layouts.create!(:identifier => 'test')
    page_1r = @site_a.pages.create!(:slug => 'root', :layout => layout)
    page_1a = @site_a.pages.create!(:slug => 'test_a', :layout => layout)
    page_1b = @site_a.pages.create!(:slug => 'test_b', :layout => layout)
    
    assert page_2r = page_1r.mirrors.first
    assert page_2a = page_1a.mirrors.first
    assert page_2b = page_1b.mirrors.first
    
    assert_difference ['@site_a.pages.count', '@site_b.pages.count'], -1 do
      page_1a.destroy
      assert_nil Cms::Page.find_by_id(page_2a.id)
    end
    
    assert_difference ['@site_a.pages.count', '@site_b.pages.count'], -2 do
      page_1r.destroy
      assert_nil Cms::Page.find_by_id(page_2r.id)
    end
  end
  
  def test_snippet_destroy
    setup_sites
    snippet_1 = @site_a.snippets.create(:identifier => 'test')
    assert snippet_2 = snippet_1.mirrors.first
    
    assert_difference ['@site_a.snippets.count', '@site_b.snippets.count'], -1 do
      snippet_1.destroy
      assert_nil Cms::Snippet.find_by_id(snippet_2.id)
    end
  end
  
  def test_site_creation_as_mirror
    site = cms_sites(:default)
    Cms::Site.update_all(:is_mirrored => true) # bypassing callbacks
    
    assert_difference 'Cms::Site.count' do
      assert_difference 'Cms::Layout.count', site.layouts.count do
        assert_difference 'Cms::Page.count', site.pages.count do
          assert_difference 'Cms::Snippet.count', site.snippets.count do
            mirror = Cms::Site.create!(
              :identifier   => 'mirror',
              :hostname     => 'mirror.host',
              :is_mirrored  => true
            )
          end
        end
      end
    end
  end
  
  def test_site_update_to_mirror
    site = cms_sites(:default)
    Cms::Site.update_all(:is_mirrored => true) # bypassing callbacks
    
    mirror = Cms::Site.create!(
      :identifier => 'mirror',
      :hostname   => 'mirror.host'
    )
    layout = mirror.layouts.create!(
      :identifier => 'mirror_layout'
    )
    home_page = mirror.pages.create!(
      :label  => 'mirror home',
      :layout => layout
    )
    child_page = mirror.pages.create!(
      :label  => 'mirror child',
      :layout => layout,
      :slug   => 'mirror-child',
      :parent => home_page
    )
    snippet = mirror.snippets.create!(
      :identifier => 'mirror_snippet'
    )
    
    assert_difference ['site.layouts.count', 'site.pages.count', 'site.snippets.count'], 1 do
      assert_difference 'mirror.layouts.count', 3 do
        assert_difference 'mirror.pages.count', 1 do
          assert_difference 'mirror.snippets.count', 1 do
            
            mirror.update_attributes(:is_mirrored => true)
            
            site.reload
            assert site.layouts.where(:identifier => 'mirror_layout').present?
            assert site.pages.where(:slug => 'mirror-child').present?
            assert site.snippets.where(:identifier => 'mirror_snippet').present?
            
            mirror.reload
            assert mirror.layouts.where(:identifier => 'default').present?
            assert mirror.pages.where(:slug => 'child-page').present?
            assert mirror.snippets.where(:identifier => 'default').present?
          end
        end
      end
    end
  end
  
  def test_site_destruction
    site = cms_sites(:default)
    Cms::Site.update_all(:is_mirrored => true) # bypassing callbacks
    
    mirror = Cms::Site.create!(
      :identifier   => 'mirror',
      :hostname     => 'mirror.host',
      :is_mirrored  => true
    )
    mirror.reload
    assert_no_difference ['site.layouts.count', 'site.pages.count', 'site.snippets.count'] do
      mirror.destroy
      site.reload
    end
  end
  
protected
  
  def setup_sites
    Cms::Site.delete_all
    @site_a = Cms::Site.create!(:identifier => 'site_a', :hostname => 'site-a.host', :is_mirrored => true)
    @site_b = Cms::Site.create!(:identifier => 'site_b', :hostname => 'site-b.host', :is_mirrored => true)
  end
  
end