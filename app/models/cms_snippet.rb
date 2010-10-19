class CmsSnippet < ActiveRecord::Base
  
  # -- Relationships --------------------------------------------------------
  belongs_to :cms_site
  
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
    find_by_slug(slug) || new(:slug => slug)
  end
  
end
