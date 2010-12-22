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
    load_for_slug(cms_page.cms_site, slug) || new(:slug => slug)
  end
  
  # Attempting to initialize snippet object from yaml file that is found in config.seed_data_path
  def self.load_from_file(site, name)
    return nil if ComfortableMexicanSofa.config.seed_data_path.blank?
    file_path = "#{ComfortableMexicanSofa.config.seed_data_path}/#{site.hostname}/snippets/#{name}.yml"
    return nil unless File.exists?(file_path)
    attributes = YAML.load_file(file_path).symbolize_keys!
    new(attributes)
  rescue
    raise "Failed to load from #{file_path}"
  end
  
  # Wrapper around load_from_file and find_by_slug
  # returns layout object if loaded / found
  def self.load_for_slug!(site, slug)
    if ComfortableMexicanSofa.configuration.seed_data_path
      load_from_file(site, slug)
    else
      # FIX: This a bit odd... Snippet is used as a tag, so sometimes there's no site scope
      # being passed. So we're enforcing this only if it's found. Need to review.
      conditions = site ? {:conditions => {:cms_site_id => site.id}} : {}
      find_by_slug(slug, conditions)
    end || raise(ActiveRecord::RecordNotFound, "CmsSnippet with slug: #{slug} cannot be found")
  end
  
  # Non-blowing-up version of the method above
  def self.load_for_slug(site, slug)
    load_for_slug!(site, slug) 
  rescue ActiveRecord::RecordNotFound
    nil
  end
  
protected
  
  # Note: This might be slow. We have no idea where the snippet is used, so
  # gotta reload every single page. Kinda sucks, but might be ok unless there
  # are hundreds of pages.
  def clear_cached_page_content
    CmsPage.all.each{ |page| page.save! }
  end
  
end
