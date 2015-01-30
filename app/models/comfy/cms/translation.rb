# Abstract class for translations.

class Comfy::Cms::Translation < ActiveRecord::Base
  self.table_name = 'comfy_cms_translations'

  cms_manageable
  cms_has_revisions_for :blocks_attributes

  belongs_to :translateable, polymorphic: true

  validates :translateable, presence: true
  validates :locale, presence: true, uniqueness: { scope: :translateable_id }

  delegate :site, to: :translateable

  scope :published, -> { where(:is_published => true) }
end
