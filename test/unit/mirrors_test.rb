require File.expand_path('../test_helper', File.dirname(__FILE__))

class MirrorsTest < ActiveSupport::TestCase
  
  def setup
    ComfortableMexicanSofa.config.enable_mirror_sites = true
    load(File.expand_path('app/models/cms/layout.rb', Rails.root))
    load(File.expand_path('app/models/cms/page.rb', Rails.root))
    load(File.expand_path('app/models/cms/snippet.rb', Rails.root))
    Cms::Site.delete_all
    @site_a = Cms::Site.create!(:label => 'Site A', :hostname => 'site-a.host')
    @site_b = Cms::Site.create!(:label => 'Site B', :hostname => 'site-b.host')
  end
  
  def test_layout_creation
    assert_difference 'Cms::Layout.count', 2 do
      layout = @site_a.layouts.create!(:slug => 'test')
      assert_equal 1, layout.mirrors.size
      assert_equal 'test', layout.mirrors.first.slug
    end
  end
  
  def test_page_creation
    layout = @site_a.layouts.create!(:slug => 'test')
    
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
    assert_difference 'Cms::Snippet.count', 2 do
      snippet = @site_a.snippets.create(:slug => 'test')
      assert_equal 1, snippet.mirrors.size
      assert_equal 'test', snippet.mirrors.first.slug
    end
  end
  
  def test_layout_update
    layout_1a = @site_a.layouts.create!(:slug => 'test_a')
    layout_1b = @site_a.layouts.create!(:slug => 'test_b')
    layout_1c = @site_a.layouts.create!(:slug => 'nested', :parent => layout_1a)
    
    assert layout_2a = layout_1a.mirrors.first
    assert layout_2b = layout_1b.mirrors.first
    assert layout_2c = layout_1c.mirrors.first
    assert_equal layout_2a, layout_2c.parent
    
    layout_1c.update_attributes!(
      :slug     => 'updated',
      :parent   => layout_1b,
      :content  => 'updated content'
    )
    layout_2c.reload
    assert_equal 'updated', layout_2c.slug
    assert_equal layout_2b, layout_2c.parent
    assert_not_equal 'updated content', layout_2c
  end
  
  def test_page_update
    layout_1a = @site_a.layouts.create!(:slug => 'test_a')
    layout_1b = @site_a.layouts.create!(:slug => 'test_b')
    
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
    snippet_1 = @site_a.snippets.create(:slug => 'test')
    assert snippet_2 = snippet_1.mirrors.first
    snippet_1.update_attributes!(
      :slug     => 'updated',
      :content  => 'updated content'
    )
    snippet_2.reload
    assert_equal 'updated', snippet_2.slug
    assert_not_equal 'updated content', snippet_2.content
  end
  
  def test_layout_destroy
    layout_1a = @site_a.layouts.create!(:slug => 'test_a')
    layout_1b = @site_a.layouts.create!(:slug => 'test_b')
    layout_1c = @site_a.layouts.create!(:slug => 'nested', :parent => layout_1b)
    
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
    layout = @site_a.layouts.create!(:slug => 'test')
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
    snippet_1 = @site_a.snippets.create(:slug => 'test')
    assert snippet_2 = snippet_1.mirrors.first
    
    assert_difference ['@site_a.snippets.count', '@site_b.snippets.count'], -1 do
      snippet_1.destroy
      assert_nil Cms::Snippet.find_by_id(snippet_2.id)
    end
  end
  
end