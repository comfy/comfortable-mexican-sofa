class CmsPage < ActiveRecord::Base
  
  # -- AR Extensions --------------------------------------------------------
  acts_as_tree :counter_cache => :children_count
  
  attr_accessor :cms_tags
  
  # -- Relationships --------------------------------------------------------
  belongs_to :cms_site
  belongs_to :cms_layout
  belongs_to :target_page,
    :class_name => 'CmsPage'
  has_many :cms_blocks,
    :dependent  => :destroy
  accepts_nested_attributes_for :cms_blocks
  
  # -- Callbacks ------------------------------------------------------------
  before_validation :assign_full_path
  after_save        :sync_child_pages
  
  # -- Validations ----------------------------------------------------------
  validates :cms_site_id, 
    :presence   => true
  validates :label,
    :presence   => true
  validates :slug,
    :presence   => true,
    :format     => /^\w[a-z0-9_-]*$/i,
    :unless     => lambda{ |p| p == CmsPage.root || CmsPage.count == 0 }
  validates :cms_layout,
    :presence   => true
  validates :full_path,
    :presence   => true,
    :uniqueness => { :scope => :cms_site_id }
  validate :validate_target_page
  
  # -- Class Methods --------------------------------------------------------
  # Tree-like structure for pages
  def self.options_for_select(cms_site, cms_page = nil, current_page = nil, depth = 0, exclude_self = true, spacer = '. . ')
    return [] if (current_page ||= cms_site.cms_pages.root) == cms_page && exclude_self || !current_page
    out = []
    out << [ "#{spacer*depth}#{current_page.label}", current_page.id ] unless current_page == cms_page
    current_page.children.each do |child|
      out += options_for_select(cms_site, cms_page, child, depth + 1, exclude_self, spacer)
    end
    return out.compact
  end
  
  # Attempting to initialize page object from yaml file that is found in config.seed_data_path
  # This file defines all attributes of the page plus all the block information
  def self.load_from_file(site, path)
    return nil if ComfortableMexicanSofa.config.seed_data_path.blank?
    path = (path == '/')? '/index' : path.to_s.chomp('/')
    file_path = "#{ComfortableMexicanSofa.config.seed_data_path}/#{site.hostname}/pages#{path}.yml"
    return nil unless File.exists?(file_path)
    attributes              = YAML.load_file(file_path).symbolize_keys!
    attributes[:cms_layout] = CmsLayout.load_from_file(site, attributes[:cms_layout])
    attributes[:parent]     = CmsPage.load_from_file(site, attributes[:parent])
    attributes[:cms_site]   = site
    new(attributes)
  end
  
  # Wrapper around load_from_file and find_by_full_path
  # returns page object if loaded / found
  def self.load_for_full_path!(site, path)
    if ComfortableMexicanSofa.configuration.seed_data_path
      load_from_file(site, path)
    else
      site.cms_pages.find_by_full_path(path)
    end || raise(ActiveRecord::RecordNotFound, "CmsPage with path: #{path} cannot be found")
  end
  
  # Non-blowing-up version of the method above
  def self.load_for_full_path(site, path)
    load_for_full_path!(site, path) 
  rescue ActiveRecord::RecordNotFound
    nil
  end
  
  # -- Instance Methods -----------------------------------------------------
  # Processing content will return rendered content and will populate 
  # self.cms_tags with instances of CmsTag
  def content
    cms_layout ? CmsTag.process_content(self, cms_layout.merged_content) : ''
  end
  
  # Array of cms_tags for a page. Content generation is called if forced.
  # These also include initialized cms_blocks if present
  def cms_tags(force = false)
    self.content if force
    @cms_tags ||= []
  end
  
protected
  
  def assign_full_path
    self.full_path = self.parent ? "#{self.parent.full_path}/#{self.slug}".squeeze('/') : '/'
  end
  
  def validate_target_page
    return unless self.target_page
    p = self
    while p.target_page do
      return self.errors.add(:target_page_id, 'Invalid Redirect') if (p = p.target_page) == self
    end
  end
  
  # Forcing re-saves for child pages so they can update full_paths
  def sync_child_pages
    children.each{ |p| p.save! } if full_path_changed?
  end
  
end
