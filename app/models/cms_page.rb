# CmsPage has two collections: cms_tags and cms_blocks
# These are two different collections for the same type of objects. 
# cms_tags derived from Layout content, cms_blocks are tags (subclasses of CmsBlock)
# that are stored in the database for a particular page

class CmsPage < ActiveRecord::Base
  
  # -- AR Extensions --------------------------------------------------------
  acts_as_tree :counter_cache => :children_count
  
  attr_accessor :cms_tags
  
  # -- Relationships --------------------------------------------------------
  belongs_to :cms_layout
  has_many :cms_uploads,
    :dependent  => :destroy
  has_many :cms_blocks,
    :dependent  => :destroy
  accepts_nested_attributes_for :cms_blocks
  
  # -- Callbacks ------------------------------------------------------------
  before_validation :assign_full_path
  after_save        :sync_child_pages
  
  # -- Validations ----------------------------------------------------------
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
    :uniqueness => true
  
  # -- Class Methods --------------------------------------------------------
  # Tree-like structure for pages
  def self.options_for_select(cms_page = nil, current_page = nil, depth = 0, spacer = '. . ')
    return [] if (current_page ||= CmsPage.root) == cms_page
    out = [[ "#{spacer*depth}#{current_page.label}", current_page.id ]]
    current_page.children.each do |child|
      out += options_for_select(cms_page, child, depth + 1, spacer)
    end
    return out.compact
  end
  
  # -- Instance Methods -----------------------------------------------------
  # Processing content will return rendered content and all tags that were used.
  def content
    cms_layout ? CmsTag.process_content(self, cms_layout.content.dup) : ''
  end
  
  def cms_tags
    @cms_tags ||= []
  end
  
protected
  
  def assign_full_path
    self.full_path = self.parent ? "#{self.parent.full_path}/#{self.slug}".squeeze('/') : '/'
  end
  
  # Forcing re-saves for child pages so they can update full_paths
  def sync_child_pages
    children.each{ |p| p.save! } if full_path_changed?
  end
  
end
