# encoding: utf-8

class Cms::Page < ActiveRecord::Base
  
  ComfortableMexicanSofa.establish_connection(self)
    
  self.table_name = 'cms_pages'
  
  cms_acts_as_tree :counter_cache => :children_count
  cms_is_categorized
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
                    :assign_parent

  before_create     :assign_position
  after_save        :trigger_page_content_callbacks

  # -- Validations ----------------------------------------------------------
  validates :site_id, 
    :presence   => true
  validates :label,
    :presence   => true
  validates :layout,
    :presence   => true
  validate :validate_target_page
  
  # -- Scopes ---------------------------------------------------------------
  default_scope -> { order('cms_pages.position') }
  scope :published, -> { where(:is_published => true) }
  scope :with_full_path_and_identifier, lambda { |full_path, identifier, site = nil|
    site ||= Cms::Site.first
    includes(:page_contents => :variations).
    where(
      :cms_page_contents => {:full_path  => full_path}, 
      :cms_variations    => {:identifier => identifier},
      :cms_pages         => {:is_published => true},
      :site              => site)
  }
  scope :with_full_path, lambda { |full_path, site = nil| 
    site ||= Cms::Site.first
    includes(:page_contents).
    where(
      :cms_page_contents => {:full_path  => full_path}, 
      :cms_pages         => {:is_published => true},
      :site              => site)
  }

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

  def self.page_content_by_full_path_and_variation(full_path, variation_identifier, site = nil)
    site ||= Cms::Site.first
    if variation_identifier
      result = site.pages.includes(:page_contents, :variations).where(
        :variations    => {:identifier => variation_identifier},
        :page_contents => {:full_path => full_path}
      )
    else
      result = site.pages.includes(:page_contents, :variations).where(
        :page_contents => {:full_path => full_path}
      )
    end
    result
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
    pc_id = attrs.delete(:id).to_i
    pc =  self.page_contents.detect{|pc| pc.id == pc_id} ||
          self.page_contents.build
    pc.attributes = attrs

    # setting current page.page_content accessor
    self.page_content = pc
  end

  def default_slug
    self.page_content.slug
  end

  def has_variation?(identifier)
    result = self.page_contents.joins(:variations).where('cms_variations.identifier' => identifier)
    if identifier.is_a?(Array)
      return result.count == identifier.count
    else
      result.first
    end
  end

protected

  def assigns_label
    self.label = self.label.blank? ? "Untitled" : self.label
  end
  
  def assign_parent
    return unless site
    self.parent ||= site.pages.root unless self == site.pages.root || site.pages.count == 0
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

  def trigger_page_content_callbacks
    self.page_contents.each do |pc|
      pc.assign_full_path
      pc.save
    end
  end

end
