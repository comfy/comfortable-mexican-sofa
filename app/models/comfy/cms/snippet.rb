# frozen_string_literal: true

class Comfy::Cms::Snippet < ActiveRecord::Base
  self.table_name = 'comfy_cms_snippets'

  include Comfy::Cms::WithCategories

  cms_has_revisions_for :content

  # -- Relationships -----------------------------------------------------------
  belongs_to :site

  # -- Callbacks ---------------------------------------------------------------
  before_validation :assign_label
  before_create :assign_position
  after_save    :clear_page_content_cache
  after_destroy :clear_page_content_cache

  # -- Validations -------------------------------------------------------------
  validates :label,
            presence: true
  validates :identifier,
            presence: true,
            uniqueness: { scope: :site_id },
            format: { with: %r{\A\w[a-z0-9_-]*\z}i }

protected

  def assign_label
    self.label = label.blank? ? identifier.try(:titleize) : label
  end

  # When snippet is changed or removed we need to blow away all page caches as
  # we don't know where it was used.
  def clear_page_content_cache
    Comfy::Cms::Page.where(id: site.pages.pluck(:id)).update_all(content_cache: nil)
  end

  def assign_position
    max = site.snippets.maximum(:position)
    self.position = max ? max + 1 : 0
  end
end
