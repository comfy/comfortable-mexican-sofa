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
    if ComfortableMexicanSofa.configuration.seed_data_path
      CmsTag::Snippet.load_from_file(cms_page.cms_site, slug)
    else
      find_by_slug(slug)
    end || new(:slug => slug)
  end
  
  # Attempting to initialize snippet object from yaml file that is found in config.seed_data_path
  def self.load_from_file(site, name)
    return nil if ComfortableMexicanSofa.config.seed_data_path.blank?
    file_path = "#{ComfortableMexicanSofa.config.seed_data_path}/#{site.hostname}/snippets/#{name}.yml"
    return nil unless File.exists?(file_path)
    attributes = YAML.load_file(file_path).symbolize_keys!
    new(attributes)
  end
  
end
