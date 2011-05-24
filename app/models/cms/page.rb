class Cms::Page < ActiveRecord::Base
  
  set_table_name :cms_pages
  
  acts_as_tree :counter_cache => :children_count
  is_mirrored
  has_revisions_for :blocks_attributes
  
  attr_accessor :tags,
                :blocks_attributes_changed
  
  # -- Relationships --------------------------------------------------------
  belongs_to :site
  belongs_to :layout
  belongs_to :target_page,
    :class_name => 'Cms::Page'
  has_many :blocks,
    :dependent  => :destroy,
    :autosave   => true
  
  # -- Callbacks ------------------------------------------------------------
  before_validation :assigns_label,
                    :assign_parent,
                    :assign_full_path
  before_validation :assign_position,
                    :on => :create
  before_save :set_cached_content
  after_save  :sync_child_pages
  
  # -- Validations ----------------------------------------------------------
  validates :site_id, 
    :presence   => true
  validates :label,
    :presence   => true
  validates :slug,
    :presence   => true,
    :format     => /^\w[a-z0-9_-]*$/i,
    :unless     => lambda{ |p| p.site && (p.site.pages.count == 0 || p.site.pages.root == self) }
  validates :layout,
    :presence   => true
  validates :full_path,
    :presence   => true,
    :uniqueness => { :scope => :site_id }
  validate :validate_target_page
  
  # -- Scopes ---------------------------------------------------------------
  default_scope order(:position)
  scope :published, where(:is_published => true)
  
  # -- Class Methods --------------------------------------------------------
  # Tree-like structure for pages
  def self.options_for_select(site, page = nil, current_page = nil, depth = 0, exclude_self = true, spacer = '. . ')
    return [] if (current_page ||= site.pages.root) == page && exclude_self || !current_page
    out = []
    out << [ "#{spacer*depth}#{current_page.label}", current_page.id ] unless current_page == page
    current_page.children.each do |child|
      out += options_for_select(site, page, child, depth + 1, exclude_self, spacer)
    end
    return out.compact
  end
  
  # -- Instance Methods -----------------------------------------------------
  # For previewing purposes sometimes we need to have full_path set
  def full_path
    self.read_attribute(:full_path) || self.assign_full_path
  end
  
  # Transforms existing cms_block information into a hash that can be used
  # during form processing. That's the only way to modify cms_blocks.
  def blocks_attributes(was = false)
    self.blocks.collect do |block|
      block_attr = {}
      block_attr[:label]    = block.label
      block_attr[:content]  = was ? block.content_was : block.content
      block_attr
    end
  end
  
  # Array of block hashes in the following format:
  #   [
  #     { :label => 'block_1', :content => 'block content' },
  #     { :label => 'block_2', :content => 'block content' }
  #   ]
  def blocks_attributes=(block_hashes = [])
    block_hashes.each do |block_hash|
      block_hash.symbolize_keys! unless block_hash.is_a?(HashWithIndifferentAccess)
      block = self.blocks.detect{|b| b.label == block_hash[:label]} || self.blocks.build(:label => block_hash[:label])
      block.content = block_hash[:content]
      self.blocks_attributes_changed = self.blocks_attributes_changed || block.content_changed?
    end
  end
  
  # Processing content will return rendered content and will populate 
  # self.cms_tags with instances of CmsTag
  def content(force_reload = false)
    @content = read_attribute(:content)
    @content = nil if force_reload
    @content ||= begin
      self.tags = [] # resetting
      layout ? ComfortableMexicanSofa::Tag.process_content(self, layout.merged_content) : ''
    end
  end
  
  # Array of cms_tags for a page. Content generation is called if forced.
  # These also include initialized cms_blocks if present
  def tags(force_reload = false)
    self.content(true) if force_reload
    @tags ||= []
  end
  
  # Full url for a page
  def url
    "http://#{self.site.hostname}#{self.full_path}"
  end
  
  # Method to collect prevous state of blocks for revisions
  def blocks_attributes_was
    blocks_attributes(true)
  end
  
protected
  
  def assigns_label
    self.label = self.label.blank?? self.slug.try(:titleize) : self.label
  end
  
  def assign_parent
    return unless site
    self.parent ||= site.pages.root unless self == site.pages.root || site.pages.count == 0
  end
  
  def assign_full_path
    self.full_path = self.parent ? "#{self.parent.full_path}/#{self.slug}".squeeze('/') : '/'
  end
  
  def assign_position
    return unless self.parent
    max = self.parent.children.maximum(:position)
    self.position = max ? max + 1 : 0
  end
  
  def validate_target_page
    return unless self.target_page
    p = self
    while p.target_page do
      return self.errors.add(:target_page_id, 'Invalid Redirect') if (p = p.target_page) == self
    end
  end
  
  def set_cached_content
    write_attribute(:content, self.content(true))
  end
  
  # Forcing re-saves for child pages so they can update full_paths
  def sync_child_pages
    children.each{ |p| p.save! } if full_path_changed?
  end
  
end
