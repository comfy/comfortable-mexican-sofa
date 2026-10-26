# frozen_string_literal: true

class Comfy::Cms::Revision < Comfy::Cms::ApplicationRecord

  self.table_name = "comfy_cms_revisions"

  serialize :data, coder: JSON

  # -- Relationships --------------------------------------------------------
  belongs_to :record, polymorphic: true

end
