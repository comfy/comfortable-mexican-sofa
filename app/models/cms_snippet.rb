class CmsSnippet < ActiveRecord::Base
  
  # -- Relationships --------------------------------------------------------
  belongs_to :cms_site
  
  # -- Callbacks ------------------------------------------------------------
  after_save    :clear_cached_page_content
  after_destroy :clear_cached_page_content
  
  # -- Validations ----------------------------------------------------------
  validates :cms_site_id,
    :presence   => true
  validates :label,
    :presence   => true
  validates :slug,
    :presence   => true,
    :uniqueness => { :scope => :cms_site_id },
    :format     => { :with => /^\w[a-z0-9_-]*$/i }
    
  # -- Class Methods --------------------------------------------------------
  def self.content_for(slug)
    (s = find_by_slug(slug)) ? s.content : ''
  end
  
  def self.initialize_or_find(cms_page, slug)
    find_by_slug(slug, :conditions => {:cms_site_id => cms_page.cms_site.id}) ||
    new(:slug => slug, :cms_site => cms_page.cms_site)
  end
  
protected
  
  # Note: This might be slow. We have no idea where the snippet is used, so
  # gotta reload every single page. Kinda sucks, but might be ok unless there
  # are hundreds of pages.
  def clear_cached_page_content
    CmsPage.all.each{ |page| page.save! }
  end
  
end
