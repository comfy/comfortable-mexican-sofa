# frozen_string_literal: true

class Comfy::Cms::Page < Comfy::Cms::ApplicationRecord
  include Comfy::Cms::ActsAsTreeConcern
  include Comfy::Cms::WithFragmentsConcern
  include Comfy::Cms::WithCategories

  self.table_name = "comfy_cms_pages"

  cms_has_revisions_for :fragments_attributes

  attr_accessor :content

  # -- Relationships -----------------------------------------------------------
  belongs_to :site

  belongs_to :target_page,
    class_name: "Comfy::Cms::Page",
    optional:   true

  has_many :translations,
    dependent: :destroy

  # -- Callbacks ---------------------------------------------------------------
  before_validation :assign_label,
    :assign_parent,
    :assign_full_path

  before_create :assign_position

  after_save :sync_child_full_paths!

  # -- Validations -------------------------------------------------------------
  validates :label,
    presence: true

  validates :slug,
    presence:   { unless: :root_page? },
    absence:    { if: :root_page? },
    uniqueness: { scope: %i[site_id parent_id] },
    format:     {
      with:        /\A[\p{L}\p{N}][\p{L}\p{N}\p{M}]*(?:[._-][\p{L}\p{N}][\p{L}\p{N}\p{M}]*)*\z/,
      allow_blank: true
    }

  validate :validate_target_page

  # -- Scopes ------------------------------------------------------------------
  scope :published, -> { where(is_published: true) }

  # -- Instance Methods --------------------------------------------------------
  # For previewing purposes sometimes we need to have full_path set.
  def full_path
    read_attribute(:full_path) || assign_full_path
  end

  # # Somewhat unique method of identifying a page that is not a full_path
  # def identifier
  #   parent_id.blank? ? "index" : full_path[1..-1].parameterize
  # end

  # Full url for a page
  def url(relative: false)
    [site.url(relative: relative), full_path].join("/")
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

  def root_page?
    site && (site.pages.reload.empty? || site.pages.root == self)
  end

  def assign_label
    return if slug.blank? || label.present?

    self.label = slug.titleize
  end

  # Assigning parent page in case it wasn't explicitly provided
  def assign_parent
    return if site.blank? || parent.present? || self == site.pages.root

    self.parent = site.pages.root
  end

  def assign_full_path
    self.full_path = [parent&.full_path, slug].compact_blank.join("/")
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
        return errors.add(:target_page_id, "Invalid Redirect")
      end
    end
  end

  # Forcing re-saves for child pages so they can update full_paths
  def sync_child_full_paths!
    return unless full_path_previously_changed?
    children.each do |p|
      p.update_attribute(:full_path, p.send(:assign_full_path))
    end
  end
end
