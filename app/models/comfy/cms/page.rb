# frozen_string_literal: true

class Comfy::Cms::Page < ActiveRecord::Base
  self.table_name = 'comfy_cms_pages'

  include Comfy::Cms::WithFragments
  include Comfy::Cms::WithCategories

  cms_acts_as_tree counter_cache: :children_count, order: :position
  cms_has_revisions_for :fragments_attributes

  attr_accessor :content

  # -- Relationships -----------------------------------------------------------
  belongs_to :site
  belongs_to :target_page,
             class_name: 'Comfy::Cms::Page',
             optional: true

  has_many :translations,
           dependent: :destroy

  # -- Callbacks ---------------------------------------------------------------
  before_validation :assigns_label,
                    :assign_parent,
                    :escape_slug,
                    :assign_full_path
  before_create     :assign_position
  after_save        :sync_child_full_paths!
  after_find        :unescape_slug_and_path

  # -- Validations -------------------------------------------------------------
  validates :label,
            presence: true
  validates :slug,
            presence: true,
            uniqueness: { scope: :parent_id },
            unless: ->(p) {
              p.site && (p.site.pages.count.zero? || p.site.pages.root == self)
            }
  validate :validate_target_page
  validate :validate_format_of_unescaped_slug

  # -- Scopes ------------------------------------------------------------------
  scope :published, -> { where(is_published: true) }

  # -- Class Methods -----------------------------------------------------------
  # Tree-like structure for pages
  def self.options_for_select(site:, current_page: nil, exclude_self: false)
    options = []

    options_for_page = ->(page, depth = 0) do
      return if page.nil?
      return if exclude_self && page == current_page

      options << ["#{'. . ' * depth}#{page.label}", page.id]

      page.children.order(:position).each do |child_page|
        options_for_page.call(child_page, depth + 1)
      end
    end

    options_for_page.call(site.pages.root)

    options
  end

  # -- Instance Methods --------------------------------------------------------
  # For previewing purposes sometimes we need to have full_path set. This
  # full path take care of the pages and its childs but not of the site path
  def full_path
    read_attribute(:full_path) || assign_full_path
  end

  # Somewhat unique method of identifying a page that is not a full_path
  def identifier
    parent_id.blank? ? 'index' : full_path[1..].parameterize
  end

  # Full url for a page
  def url(relative: false)
    [site.url(relative: relative), full_path].compact.join
  end

  # This method will mutate page object by transfering attributes from translation
  # for a given locale.
  def translate!
    # If site locale same as page's or there's no translastions, we do nothing
    if site.locale == I18n.locale.to_s || translations.blank?
      return
    end

    translation = translations.published.find_by!(locale: I18n.locale)
    self.layout        = translation.layout
    self.label         = translation.label
    self.content_cache = translation.content_cache

    # We can't just assign fragments as it's a relation and will write to DB
    # This has odd side-effect of preserving page's fragments and just replacing
    # them from the translation. Not an issue if all fragments match.
    self.fragments_attributes = translation.fragments_attributes
    readonly!

    self
  end

protected

  def assigns_label
    self.label = label.blank? ? slug.try(:titleize) : label
  end

  def assign_parent
    return unless site

    self.parent ||= site.pages.root unless self == site.pages.root || site.pages.count.zero?
  end

  def assign_full_path
    self.full_path =
      if self.parent
        [CGI.escape(self.parent.full_path).gsub('%2F', '/'), slug].join('/').squeeze('/')
      else
        '/'
      end
  end

  def assign_position
    return unless self.parent
    return if position.to_i.positive?

    max = self.parent.children.maximum(:position)
    self.position = max ? max + 1 : 0
  end

  def validate_target_page
    return unless target_page

    p = self
    while p.target_page
      if (p = p.target_page) == self
        return errors.add(:target_page_id, 'Invalid Redirect')
      end
    end
  end

  def validate_format_of_unescaped_slug
    return unless slug.present?

    unescaped_slug = CGI.unescape(slug)
    errors.add(:slug, :invalid) unless unescaped_slug =~ %r{^\p{Alnum}[.\p{Alnum}\p{Mark}_-]*$}i
  end

  # Forcing re-saves for child pages so they can update full_paths
  def sync_child_full_paths!
    return unless full_path_previously_changed?

    children.each do |p|
      p.update_attribute(:full_path, p.send(:assign_full_path))
    end
  end

  # Escape slug unless it's nonexistent (root)
  def escape_slug
    self.slug = CGI.escape(slug) unless slug.nil?
  end

  # Unescape the slug and full path back into their original forms unless they're nonexistent
  def unescape_slug_and_path
    self.slug       = CGI.unescape(slug)      unless slug.nil?
    self.full_path  = CGI.unescape(full_path) unless full_path.nil?
  end
end
