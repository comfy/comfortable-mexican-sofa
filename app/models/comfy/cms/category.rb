# frozen_string_literal: true

class Comfy::Cms::Category < ActiveRecord::Base
  self.table_name = 'comfy_cms_categories'

  # -- Relationships --------------------------------------------------------
  belongs_to :site
  has_many :categorizations,
           dependent: :destroy

  # -- Validations ----------------------------------------------------------
  validates :label,
            presence: true,
            uniqueness: { scope: %i[categorized_type site_id] }
  validates :categorized_type,
            presence:   true

  # -- Scopes ---------------------------------------------------------------
  scope :of_type, ->(type) {
    where(categorized_type: type)
  }
end
