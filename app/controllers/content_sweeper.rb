class ContentSweeper < ActionController::Caching::Sweeper
  observe CmsPage # This sweeper is going to keep an eye on the CmsPage model
 
  # If our sweeper detects that a CmsPage was created call this
  def after_create(cms_page)
    puts "cms_page: #{cms_page.slug} saved!!!"
          expire_cache_for(cms_page)
  end
 
  # If our sweeper detects that a CmsPage was updated call this
  def after_update(cms_page)
    puts "cms_page: #{cms_page.slug} saved!!!"
          expire_cache_for(cms_page)
  end
 
  # If our sweeper detects that a CmsPage was deleted call this
  def after_destroy(cms_page)
          expire_cache_for(cms_page)
  end
 
  private
  def expire_cache_for(cms_page)
    # Expire the index page now that we added a new product
    puts "expiring path #{cms_page.full_path}!!!"
    expire_page(cms_page.full_path)
  end
end
