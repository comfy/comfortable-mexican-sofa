# frozen_string_literal: true

class Comfy::Cms::Revision < ActiveRecord::Base
  self.table_name = 'comfy_cms_revisions'

  serialize :data, coder: Psych

  # -- Relationships --------------------------------------------------------
  belongs_to :record, polymorphic: true
end
