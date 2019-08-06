# frozen_string_literal: true

class Comfy::Cms::Revision < ComfortableMexicanSofa.config.base_model.to_s.constantize

  self.table_name = "comfy_cms_revisions"

  serialize :data

  # -- Relationships --------------------------------------------------------
  belongs_to :record, polymorphic: true

end
