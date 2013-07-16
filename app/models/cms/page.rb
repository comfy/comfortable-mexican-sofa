# encoding: utf-8

class Cms::Page < ActiveRecord::Base
  
  ComfortableMexicanSofa.establish_connection(self)
    
  self.table_name = 'cms_pages'
  
  cms_acts_as_tree :counter_cache => :children_count
  cms_is_categorized
  cms_is_mirrored
  # TODO
  # cms_has_revisions_for :blocks_attributes
  
  attr_accessor :page_content
  
  # -- Relationships --------------------------------------------------------
  belongs_to :site
  belongs_to :layout,
    :inverse_of => :pages
  belongs_to :target_page,
    :class_name => 'Cms::Page'
  has_many :page_contents,
    :inverse_of => :page,
    :autosave   => true,
    :dependent  => :destroy
  
  # -- Callbacks ------------------------------------------------------------
  before_validation :assigns_label,
                    :assign_parent,
                    :escape_slug,
                    :assign_full_path

  before_create     :assign_position
  after_save        :sync_child_pages
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
    end
    return out.compact
  end
  
  # -- Instance Methods -----------------------------------------------------
  # For previewing purposes sometimes we need to have full_path set. This
  # full path take care of the pages and its childs but not of the site path
  def full_path
    self.read_attribute(:full_path) || self.assign_full_path
  end

  # Full url for a page
  def url
    "http://" + "#{self.site.hostname}/#{self.site.path}/#{self.full_path}".squeeze("/")
  end

  def content(variation = nil)
    self.page_contents.for_variation(variation).first.try(:content)
  end
  
  # Grabbing page content object that is currently assigned to page
  # Or builds a new one just so there's something
  # Also can grab page content for a provided variation
  def page_content(variation = nil, reload = false)
    @page_content = nil if reload
    @page_content ||= begin
      pc =  self.page_contents.for_variation(variation).first ||
            self.page_contents.build
      pc.page = self
      pc
    end
  end

  # Assigning page content attributes. Applying them either to a new or existing
  # page content object depending on the passed id
  def page_content_attributes=(attrs)
    return unless attrs.is_a?(Hash)
    
    pc =  self.page_contents.detect{|pc| pc.id = attrs.delete(:id)} ||
          self.page_contents.build
    pc.attributes = attrs
    
    # setting current page.page_content accessor
    self.page_content = pc
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

  # Forcing re-saves for child pages so they can update full_paths
  def sync_child_pages
    children.each{ |p| p.save! } if full_path_changed?
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
