# encoding: utf-8

class Comfy::Cms::Page < ActiveRecord::Base
  self.table_name = 'comfy_cms_pages'

  cms_acts_as_tree :counter_cache => :children_count
  cms_is_categorized
  cms_is_mirrored
  cms_manageable
  cms_has_revisions_for :blocks_attributes
  cms_has_slug
  cms_is_translateable

  # -- Relationships --------------------------------------------------------
  belongs_to :site
  belongs_to :layout
  belongs_to :target_page,
    :class_name => 'Comfy::Cms::Page'

  # -- Callbacks ------------------------------------------------------------
  before_validation :assigns_label,
                    :assign_parent
  before_create     :assign_position
  after_save        :sync_child_full_paths!, if: :full_path_changed?

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

  # Somewhat unique method of identifying a page that is not a full_path
  def identifier
    self.parent_id.blank? ? 'index' : self.full_path[1..-1].slugify
  end

  # Finds a page by its path or its translated path.
  # Tries to load translation if locale is specified.
  # Returns only published pages and translations by default.
  # Returns *nil* if no page was found.
  #
  #   @cms_site.pages.find_page('/')
  #   @cms_site.pages.find_page('/', locale: :de, published: true)
  #
  def self.find_page(path, options={})
    options = { locale: nil, published: true }.merge(options)

    page = where(full_path: path)
    page = page.where(is_published: true) if options[:published]
    page = page.first

    # If the page was not found try to find it via its translated paths.
    # It will only return published translations if the published option is *true*.
    # If a translation is found it won't check if the page itself is published though.
    # That way you can fetch translated pages even if the default language page is
    # not yet published.
    if page.nil? && options[:locale]
      translation = reflect_on_association(:translations).klass.where(full_path: path, locale: options[:locale])
      translation = translation.where(is_published: true) if options[:published]
      page = translation.first.try(:translateable)
    end

    # Try to translate the page.
    # If a translation is found it is saved on the *translation* attribute.
    # Methods like <tt>content_cache</tt> or <tt>target_page</tt> will then load
    # content from that translation instead of from the page.
    # It will only return published translations if the published option is *true*.
    if page && options[:locale] && options[:locale].to_s != page.site.locale
      translation = page.translations.where(locale: options[:locale])
      translation = translation.where(is_published: true) if options[:published]
      page.translation = translation.first
    end

    page
  end

  # Same as <tt>find_page</tt> but raises *ActiveRecord::RecordNotFound*
  # if no page was found.
  def self.find_page!(*args)
    page = find_page(*args)
    raise ActiveRecord::RecordNotFound unless page
    page
  end

  # Will return translated content cache if translation is available. Otherwise
  # original content cache.
  def content_cache
    translation ? translation.content_cache : super
  end

  # Will return translated target page if translation is available. Otherwise
  # original target page.
  def target_page
    translation ? translation.target_page : super
  end

protected

  def assigns_label
    self.label = self.label.blank?? self.slug.try(:titleize) : self.label
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

  def sync_child_full_paths!
    children.each do |p|
      p.update_column(:full_path, p.send(:assign_full_path))
      p.send(:sync_child_full_paths!)
    end
    translations.each do |t|
      t.send(:assign_full_path)
      t.save!
    end
  end

end
