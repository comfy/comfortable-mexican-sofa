# encoding: utf-8

class Cms::Page < ActiveRecord::Base
  include Cms::Base
  
  cms_acts_as_tree :counter_cache => :children_count
  cms_is_categorized
  cms_is_mirrored
  cms_has_revisions_for :blocks_attributes
  
  attr_accessor :tags,
                :cached_content,
                :blocks_attributes_changed
  
  # -- Relationships --------------------------------------------------------
  belongs_to :site
  belongs_to :layout
  belongs_to :target_page,
    :class_name => 'Cms::Page'
  has_many :blocks,
    :autosave   => true,
    :dependent  => :destroy
  
  # -- Callbacks ------------------------------------------------------------
  before_validation :assigns_label,
                    :assign_parent,
                    :escape_slug,
                    :assign_full_path
  before_create     :assign_position
  before_save       :set_cached_content
  after_save        :sync_child_full_paths!
  after_find        :unescape_slug_and_path
  
  # -- Validations ----------------------------------------------------------
  validates :site_id, 
    :presence   => true
  validates :label,
    :presence   => true
  validates :slug,
    :presence   => true,
    :uniqueness => { :scope => :parent_id },
    :unless     => lambda{ |p| p.site && (p.site.pages.count == 0 || p.site.pages.root == self) }
  validates :layout,
    :presence   => true
  validate :validate_target_page
  validate :validate_format_of_unescaped_slug
  
  # -- Scopes ---------------------------------------------------------------
  default_scope -> { order('cms_pages.position') }
  scope :published, -> { where(:is_published => true) }
  
  # -- Class Methods --------------------------------------------------------
  # Tree-like structure for pages
  def self.options_for_select(site, page = nil, current_page = nil, depth = 0, exclude_self = true, spacer = '. . ')
    return [] if (current_page ||= site.pages.root) == page && exclude_self || !current_page
    out = []
    out << [ "#{spacer*depth}#{current_page.label}", current_page.id ] unless current_page == page
    current_page.children.each do |child|
      out += options_for_select(site, page, child, depth + 1, exclude_self, spacer)
    end if current_page.children_count.nonzero?
    return out.compact 
  end
  
  # -- Instance Methods -----------------------------------------------------
  # For previewing purposes sometimes we need to have full_path set. This
  # full path take care of the pages and its childs but not of the site path
  def full_path
    self.read_attribute(:full_path) || self.assign_full_path
  end
  
  # Somewhat unique method of identifying a page that is not a full_path
  def identifier
    self.parent_id.blank?? 'index' : self.full_path[1..-1].slugify
  end
  
  # Transforms existing cms_block information into a hash that can be used
  # during form processing. That's the only way to modify cms_blocks.
  def blocks_attributes(was = false)
    self.blocks.collect do |block|
      block_attr = {}
      block_attr[:identifier] = block.identifier
      block_attr[:content]    = was ? block.content_was : block.content
      block_attr
    end
  end
  
  # Array of block hashes in the following format:
  #   [
  #     { :identifier => 'block_1', :content => 'block content' },
  #     { :identifier => 'block_2', :content => 'block content' }
  #   ]
  def blocks_attributes=(block_hashes = [])
    block_hashes = block_hashes.values if block_hashes.is_a?(Hash)
    block_hashes.each do |block_hash|
      block_hash.symbolize_keys! unless block_hash.is_a?(HashWithIndifferentAccess)
      block = 
        self.blocks.detect{|b| b.identifier == block_hash[:identifier]} || 
        self.blocks.build(:identifier => block_hash[:identifier])
      block.content = block_hash[:content]
      self.blocks_attributes_changed = self.blocks_attributes_changed || block.content_changed?
    end
  end
  
  # Processing content will return rendered content and will populate 
  # self.cms_tags with instances of CmsTag
  def render
    @tags = [] # resetting
    return '' unless layout
    
    ComfortableMexicanSofa::Tag.process_content(
      self, ComfortableMexicanSofa::Tag.sanitize_irb(layout.merged_content)
    )
  end
  
  # Cached content accessor
  def content
    if (@cached_content = read_attribute(:content)).nil?
      @cached_content = self.render
      update_column(:content, @cached_content) unless self.new_record?
    end
    @cached_content
  end
  
  def clear_cached_content!
    self.update_column(:content, nil)
  end
  
  # Array of cms_tags for a page. Content generation is called if forced.
  # These also include initialized cms_blocks if present
  def tags(force_reload = false)
    self.render if force_reload
    @tags ||= []
  end
  
  # Full url for a page
  def url
    "//" + "#{self.site.hostname}/#{self.site.path}/#{self.full_path}".squeeze("/")
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
    self.full_path = self.parent ? "#{CGI::escape(self.parent.full_path).gsub('%2F', '/')}/#{self.slug}".squeeze('/') : '/'
  end
  
  def assign_position
    return unless self.parent
    return if self.position.to_i > 0
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
  
  def validate_format_of_unescaped_slug
    return unless slug.present?
    unescaped_slug = CGI::unescape(self.slug)
    errors.add(:slug, :invalid) unless unescaped_slug =~ /^\p{Alnum}[\.\p{Alnum}\p{Mark}_-]*$/i
  end
  
  def set_cached_content
    @cached_content = self.render
    write_attribute(:content, self.cached_content)
  end
  
  # Forcing re-saves for child pages so they can update full_paths
  def sync_child_full_paths!
    return unless full_path_changed?
    children.each do |p|
      p.update_column(:full_path, p.send(:assign_full_path))
      p.send(:sync_child_full_paths!)
    end
  end

  # Escape slug unless it's nonexistent (root)
  def escape_slug
    self.slug = CGI::escape(self.slug) unless self.slug.nil?
  end

  # Unescape the slug and full path back into their original forms unless they're nonexistent
  def unescape_slug_and_path
    self.slug       = CGI::unescape(self.slug)      unless self.slug.nil?
    self.full_path  = CGI::unescape(self.full_path) unless self.full_path.nil?
  end
  
end
