class Comfy::Cms::Translation < ActiveRecord::Base
  self.table_name = "comfy_cms_translations"

  include Comfy::Cms::WithFragments

  cms_has_revisions_for :fragments_attributes

  # -- Relationships -----------------------------------------------------------
  belongs_to :page

  # -- Callbacks ---------------------------------------------------------------
  before_validation :assign_layout

  # -- Scopes ------------------------------------------------------------------
  scope :published, -> { where(is_published: true) }

  # -- Validations -------------------------------------------------------------
  validates :label,
    presence:   true

  validates :locale,
    presence:   true,
    uniqueness: {scope: :page_id}

  validate :validate_locale

private

  def validate_locale
    return unless self.page
    errors.add(:locale) if self.locale == self.page.site.locale
  end

  def assign_layout
    self.layout ||= self.page.layout if self.page.present?
  end
end
