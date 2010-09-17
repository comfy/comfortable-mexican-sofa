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
  has_many :cms_assets,
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
  # Processing content will return rendered content and all tag that were used.
  def process_content
    CmsTag.process_content(self, cms_layout.content.dup)
  end
  
  # Initilize tags the moment layout gets assigned. This way there's no need to
  # call initialize tags manually. Need to do this on both association and 
  # foreign id assignments.
  # def cms_layout_id=(value)
  #   write_attribute(:cms_layout_id, value)
  #   self.cms_layout_with_tag_initialization = CmsLayout.find_by_id(value)
  # end
  #  
  # def cms_layout_with_tag_initialization=(value)
  #   self.cms_layout_without_tag_initialization = value
  #   self.initialize_tags
  # end
  # alias_method_chain :cms_layout=, :tag_initialization
  
  # Returns an array of tag objects, at the same time populates cms_blocks
  # of the current page
  # def initialize_tags
  #  CmsTag.initialize_tags(self)
  # end
  
  # Converting object from cms_tags collection into cms_blocks
  # TODO: Explicitely calling it. Can't really put it into a callback
  # def assign_cms_blocks!
  #   self.cms_tags.each do |tag|
  #     if block = self.cms_blocks.find_by_label(tag.label)
  #       block.type    = tag.type
  #       block.content = tag.content
  #       block.save!
  #     else
  #       self.cms_blocks.create!(:label => tag.label, :type => tag.type, :content => tag.content)
  #     end
  #   end
  # end
  
protected
  
  def assign_full_path
    self.full_path = self.parent ? "#{self.parent.full_path}/#{self.slug}".squeeze('/') : '/'
  end
  
  # Forcing re-saves for child pages so they can update full_paths
  def sync_child_pages
    children.each{ |p| p.save! } if full_path_changed?
  end
  
end
