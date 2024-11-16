# frozen_string_literal: true

class Comfy::Cms::Categorization < ActiveRecord::Base
  self.table_name = 'comfy_cms_categorizations'

  # -- Relationships -----------------------------------------------------------
  belongs_to :category
  belongs_to :categorized,
             polymorphic: true

  # -- Validations -------------------------------------------------------------
  validates :category_id,
            uniqueness: { scope: %i[categorized_type categorized_id] }
end
