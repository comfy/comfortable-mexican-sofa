class Comfy::Cms::Fragment < ActiveRecord::Base
  self.table_name = 'comfy_cms_fragments'

  serialize :content

  # -- Relationships --------------------------------------------------------
  belongs_to :page

  # -- Validations ----------------------------------------------------------
  validates :identifier,
    presence:   true,
    uniqueness: {scope: :page_id}

end
