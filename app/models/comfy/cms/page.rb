# encoding: utf-8

class Comfy::Cms::Page < ActiveRecord::Base
  self.table_name = 'comfy_cms_pages'

  cms_acts_as_tree :counter_cache => :children_count
  cms_is_categorized
  cms_is_mirrored
  cms_manageable
  cms_has_revisions_for :blocks_attributes

  # -- Relationships --------------------------------------------------------
  belongs_to :site
  belongs_to :layout
  belongs_to :target_page,
    :class_name => 'Comfy::Cms::Page'

  # -- Callbacks ------------------------------------------------------------
  before_validation :assigns_label,
                    :assign_parent,
                    :escape_slug,
                    :assign_full_path
  before_create     :assign_position
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
  default_scope -> { order('comfy_cms_pages.position') }
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

  # Full url for a page
  def url(relative = false)
    public_cms_path = ComfortableMexicanSofa.config.public_cms_path || '/'
    if relative
      [public_cms_path, self.site.path, self.full_path].join('/').squeeze('/')
    else
      '//' + [self.site.hostname, public_cms_path, self.site.path, self.full_path].join('/').squeeze('/')
    end
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
    self.full_path = self.parent ?
      [CGI::escape(self.parent.full_path).gsub('%2F', '/'), self.slug].join('/').squeeze('/') :
      '/'
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
  def sync_child_full_paths!
    return unless full_path_changed?
    children.each do |p|
      p.update_attribute(:full_path, p.send(:assign_full_path))
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
